module Montonio
  # Handles a verified Montonio order webhook.
  #
  # Montonio retries for 48 hours whenever the endpoint does not answer 2xx and
  # may deliver the same webhook more than once, so everything here is
  # idempotent and every business level problem is reported to the
  # administrators instead of being turned into an error response.
  #
  # The one exception is a paid invoice whose initiator (auction, ...) could not
  # be told about the payment: that answers :notification_failed, the controller
  # turns it into an error response, and Montonio's retry delivers the
  # notification again.
  class PaymentProcessor
    include Request

    PAID = 'PAID'.freeze
    IGNORED_STATUSES = %w[PENDING ABANDONED AUTHORIZED].freeze
    MANUAL_REVIEW_STATUSES = %w[VOIDED REFUNDED PARTIALLY_REFUNDED].freeze

    SETTLED = 'settled'.freeze
    ORDERS_KEY = 'montonio_orders'.freeze
    DISCREPANCIES_KEY = 'montonio_discrepancies'.freeze

    Result = Struct.new(:state, :message, :invoice, keyword_init: true) do
      def notification_failed?
        state == :notification_failed
      end
    end

    attr_reader :order_token

    def self.call(order_token:)
      new(order_token: order_token).call
    end

    def initialize(order_token:)
      @order_token = order_token
    end

    def call
      payload = OrderTokenVerifier.call(order_token)
      invoice = find_invoice!(payload)

      process(invoice: invoice, payload: payload)
    end

    private

    def find_invoice!(payload)
      link_uuid = payload['paymentLinkUuid']
      invoice = Invoice.find_by(payment_link_uuid: link_uuid) if link_uuid.present?

      return invoice if invoice

      raise UnknownPaymentLinkError, "No invoice found for Montonio payment link #{link_uuid.inspect}"
    end

    def process(invoice:, payload:)
      status = payload['paymentStatus'].to_s

      return already_processed(invoice, payload) if processed?(invoice, payload)
      return ignored(invoice, status) if IGNORED_STATUSES.include?(status)
      return manual_review(invoice, payload, status) if MANUAL_REVIEW_STATUSES.include?(status)
      return unexpected_status(invoice, payload, status) unless status == PAID
      return double_payment(invoice, payload) if invoice.paid?

      mismatch = amount_mismatch(invoice, payload)
      return amount_mismatch_result(invoice, payload, mismatch) if mismatch

      settle(invoice: invoice, payload: payload)
    end

    # --- outcomes -----------------------------------------------------------

    def settle(invoice:, payload:)
      ActiveRecord::Base.transaction do
        invoice.update!(status: :paid,
                        payment_reference: payload['uuid'],
                        transaction_time: transaction_time(payload),
                        payment_link_provider: PROVIDER,
                        linkpay_info: linkpay_info_with_order(invoice, payload, 'processed'))
      end

      deliver_notification(invoice: invoice, payload: payload, processed_message: 'Payment processed')
    end

    def already_processed(invoice, payload)
      Rails.logger.info("Montonio webhook replay for order #{payload['uuid']}, invoice #{invoice.invoice_number}")

      if notification_pending?(invoice, payload)
        return deliver_notification(invoice: invoice, payload: payload,
                                    processed_message: 'Payment already processed, client notified')
      end

      Result.new(state: :already_processed, message: 'Payment already processed', invoice: invoice)
    end

    def deliver_notification(invoice:, payload:, processed_message:)
      if notify_client_service(invoice: invoice, payload: payload)
        update_order(invoice, payload, 'client_notified_at' => Time.zone.now.iso8601)
        return Result.new(state: :processed, message: processed_message, invoice: invoice)
      end

      Result.new(state: :notification_failed,
                 message: "Payment processed, but #{invoice.initiator} could not be notified",
                 invoice: invoice)
    end

    def ignored(invoice, status)
      Rails.logger.debug("Montonio webhook with status #{status} ignored for invoice #{invoice.invoice_number}")

      Result.new(state: :ignored, message: "Payment status #{status} ignored", invoice: invoice)
    end

    def manual_review(invoice, payload, status)
      report(title: "Montonio payment #{status} for invoice #{invoice.invoice_number}",
             message: "Montonio reported status #{status} for order #{payload['uuid']} " \
                      "(invoice #{invoice.invoice_number}, current invoice status #{invoice.status}). " \
                      'The invoice was left untouched and needs manual handling.')

      Result.new(state: :manual_review, message: "Payment status #{status} needs manual handling", invoice: invoice)
    end

    def unexpected_status(invoice, payload, status)
      report(title: "Unknown Montonio payment status for invoice #{invoice.invoice_number}",
             message: "Montonio reported unknown status #{status.inspect} for order #{payload['uuid']} " \
                      "(invoice #{invoice.invoice_number}). The invoice was left untouched.")

      Result.new(state: :manual_review, message: "Payment status #{status} needs manual handling", invoice: invoice)
    end

    def double_payment(invoice, payload)
      record_discrepancy(invoice, payload, 'possible_double_payment')
      report(title: "Possible double payment for invoice #{invoice.invoice_number}",
             message: "Montonio order #{payload['uuid']} reported PAID for invoice #{invoice.invoice_number}, " \
                      "which is already paid by another payment (#{invoice.payment_reference}). " \
                      'No changes were made, please check manually.')

      Result.new(state: :possible_double_payment, message: 'Invoice is already paid', invoice: invoice)
    end

    def amount_mismatch_result(invoice, payload, mismatch)
      record_discrepancy(invoice, payload, mismatch)
      report(title: "Montonio payment does not match invoice #{invoice.invoice_number}",
             message: "Montonio order #{payload['uuid']} for invoice #{invoice.invoice_number} does not match: " \
                      "#{mismatch}. The invoice was NOT marked as paid.")

      Result.new(state: :amount_mismatch, message: 'Payment does not match the invoice', invoice: invoice)
    end

    # --- checks -------------------------------------------------------------

    def processed?(invoice, payload)
      uuid = payload['uuid'].to_s
      return false if uuid.blank?

      processed_orders(invoice).key?(uuid)
    end

    # Orders settled before client_notified_at existed have no failure mark
    # either, so only an explicit failure makes a replay notify again.
    def notification_pending?(invoice, payload)
      order = processed_orders(invoice)[payload['uuid'].to_s]
      order.is_a?(Hash) && order['state'] == 'processed' &&
        order['client_notified_at'].blank? && order['client_notify_failed_at'].present?
    end

    def processed_orders(invoice)
      info = invoice.linkpay_info || {}
      info[ORDERS_KEY].is_a?(Hash) ? info[ORDERS_KEY] : {}
    end

    # Returns a human readable description of the mismatch, or nil when the
    # payment matches the invoice.
    def amount_mismatch(invoice, payload)
      problems = []

      currency = payload['currency'].to_s
      problems << "currency #{currency.inspect} instead of #{CURRENCY}" if currency != CURRENCY

      paid = to_amount(payload['grandTotal'])
      expected = to_amount(invoice.transaction_amount)
      problems << "amount #{payload['grandTotal'].inspect} instead of #{expected.to_s('F')}" if paid != expected

      problems.empty? ? nil : problems.join(' and ')
    end

    def to_amount(value)
      BigDecimal(value.to_s).round(2)
    rescue ArgumentError, TypeError
      BigDecimal('-1')
    end

    # --- persistence --------------------------------------------------------

    def linkpay_info_with_order(invoice, payload, state)
      info = (invoice.linkpay_info || {}).dup
      orders = processed_orders(invoice).dup
      orders[payload['uuid'].to_s] = payload.merge('processed_at' => Time.zone.now.iso8601, 'state' => state)
      info[ORDERS_KEY] = orders

      info
    end

    def update_order(invoice, payload, attributes)
      info = (invoice.linkpay_info || {}).dup
      orders = processed_orders(invoice).dup
      uuid = payload['uuid'].to_s
      orders[uuid] = (orders[uuid] || {}).merge(attributes)
      info[ORDERS_KEY] = orders

      invoice.update!(linkpay_info: info)
    end

    def record_discrepancy(invoice, payload, reason)
      info = (invoice.linkpay_info || {}).dup
      discrepancies = info[DISCREPANCIES_KEY].is_a?(Array) ? info[DISCREPANCIES_KEY].dup : []
      discrepancies << {
        'uuid' => payload['uuid'],
        'reason' => reason,
        'payment_status' => payload['paymentStatus'],
        'grand_total' => payload['grandTotal'],
        'currency' => payload['currency'],
        'detected_at' => Time.zone.now.iso8601
      }
      info[DISCREPANCIES_KEY] = discrepancies

      invoice.update!(linkpay_info: info)
    end

    def transaction_time(payload)
      payload['iat'].present? ? Time.zone.at(payload['iat'].to_i) : Time.zone.now
    end

    # --- outbound -----------------------------------------------------------

    # Returns true when the initiator accepted the notification (or there is
    # nobody to notify), false otherwise. Administrators hear about the first
    # failure only; Montonio retries up to 13 times.
    def notify_client_service(invoice:, payload:)
      return true if invoice.billing_system?

      url = update_payment_url[invoice.initiator.to_s.to_sym]
      raise ArgumentError, "no payment status url for initiator #{invoice.initiator}" if url.blank?

      response = put_raw(direction: 'services', path: url,
                         params: notification_params(invoice: invoice, payload: payload))
      return true if response.success?

      raise "#{url} answered #{response.status}"
    rescue StandardError => e
      notification_failed(invoice: invoice, payload: payload, error: e)
      false
    end

    def notification_failed(invoice:, payload:, error:)
      Rails.logger.error("Could not notify #{invoice.initiator} about Montonio payment of invoice " \
                         "#{invoice.invoice_number}: #{error.class}: #{error.message}")

      first_failure = processed_orders(invoice).dig(payload['uuid'].to_s, 'client_notify_failed_at').blank?
      update_order(invoice, payload, 'client_notify_failed_at' => Time.zone.now.iso8601)
      return unless first_failure

      report(title: "Montonio payment notification failed for invoice #{invoice.invoice_number}",
             message: "Invoice #{invoice.invoice_number} was marked as paid, but #{invoice.initiator} " \
                      "could not be notified: #{error.class}: #{error.message}. " \
                      'Montonio retries the webhook for 48 hours, each retry notifies again.')
    end

    def notification_params(invoice:, payload:)
      amount = to_amount(payload['grandTotal'])

      {
        order_reference: invoice.invoice_number.to_s,
        payment_state: SETTLED,
        transaction_time: invoice.transaction_time&.iso8601,
        initial_amount: amount.to_f,
        standing_amount: amount.to_f,
        invoice_number_collection: nil,
        payment_reference: payload['uuid'],
        payment_provider: PROVIDER
      }
    end

    def update_payment_url
      {
        registry: GlobalVariable::REGISTRY_PAYMENT_URL,
        auction: GlobalVariable::AUCTION_PAYMENT_URL,
        eeid: GlobalVariable::EEID_PAYMENT_URL
      }
    end

    def report(title:, message:)
      Rails.logger.error(message)
      NotifierMailer.inform_admin(title, message).deliver_now
    rescue StandardError => e
      Rails.logger.error("Could not inform administrators: #{e.class}: #{e.message}")
    end
  end
end
