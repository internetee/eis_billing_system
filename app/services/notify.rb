class Notify
  include Request

  SETTLED = 'settled'.freeze
  PREPENDED = 'prepended'.freeze
  AUCTION = 'auction'.freeze
  BUSINESS_REGISTRY = 'business_registry'.freeze

  attr_reader :response

  def initialize(response:)
    @response = response
  end

  def self.call(response:)
    notifier = new(response:)

    parsed_response = notifier.parse_response(response)
    order_number = if parsed_response[:order_reference].split(', ').size > 1
                     parsed_response[:order_reference].split(', ')[0].split(':')[1]
                   else
                     parsed_response[:order_reference]
                   end

    invoice = Invoice.find_by(invoice_number: order_number)

    if invoice.nil?
      return notifier.notify(title: "Invoice with #{parsed_response[:order_reference]} number not found",
                             error_message: "Invoice with #{parsed_response[:order_reference]} number not found")
    end
    return if invoice.paid?

    notifier.update_invoice_state(parsed_response:, invoice:)
    return unless invoice.paid?
    return if invoice.billing_system?

    url = notifier.get_update_payment_url[invoice.initiator.to_sym]
    return notifier.define_for_deposit(invoice, url) if invoice.auction_deposit_prepayment?

    parsed_response[:invoice_number_collection] = notifier.invoice_numbers_from_multi_payment(invoice)

    notifier.put_request(direction: 'services', path: url, params: parsed_response)
  rescue StandardError => e
    Rails.logger.error e
    notifier.notify(title: 'Error occur in callback handler', error_message: "Error message #{e}. path: #{url}, params: #{parsed_response}, class: Notify, method: call")
  end

  def define_for_deposit(invoice, url)
    attributes = invoice.description.split(',')
    domain_name, user_uuid, user_email = attributes.map { |attr| attr.split(' ')[1] }

    params = {
      domain_name:,
      user_uuid:,
      user_email:,
      transaction_amount: invoice.transaction_amount.to_f,
      invoice_number: invoice.invoice_number,
      description: 'deposit',
      affiliation: 1
    }

    put_request(direction: 'services', path: url, params:)
  end

  def notify(title:, error_message:)
    # return if Rails.env.development?

    NotifierMailer.inform_admin(title, error_message).deliver_now
  end

  def update_invoice_state(parsed_response:, invoice:)
    status = parsed_response[:payment_state] == SETTLED ? :paid : :failed

    invoice.update(payment_reference: parsed_response[:payment_reference],
                   status:,
                   transaction_time: parsed_response[:transaction_time],
                   everypay_response: parsed_response)
  end

  def invoice_numbers_from_multi_payment(invoice)
    return if !invoice.initiator == AUCTION || invoice.description == PREPENDED || invoice.description == ''

    numbers = invoice.description.split(' ')
    results = Invoice.where(invoice_number: numbers).pluck(:invoice_number, :payment_reference)
    data = []
    results.each do |r|
      set_description_for_multiple_payment(parent_invoice: invoice, invoice_number: r[0])
      data << { number: r[0], ref: r[1] }
    end

    data
  end

  def set_description_for_multiple_payment(parent_invoice:, invoice_number:)
    invoice = Invoice.find_by(invoice_number:)

    invoice.payment_reference = parent_invoice.payment_reference
    invoice.status = parent_invoice.status
    invoice.transaction_time = parent_invoice.transaction_time
    invoice.everypay_response = parent_invoice.everypay_response
    invoice.description = "related to #{parent_invoice.invoice_number}"

    invoice.save!
  end

  def get_update_payment_url
    {
      registry: GlobalVariable::REGISTRY_PAYMENT_URL,
      auction: GlobalVariable::AUCTION_PAYMENT_URL,
      eeid: GlobalVariable::EEID_PAYMENT_URL
    }
  end

  def parse_response(response)
    {
      account_name: response['account_name'],
      order_reference: response['order_reference'],
      email: response['email'],
      customer_ip: response['customer_ip'],
      customer_url: response['customer_url'],
      payment_created_at: response['payment_created_at'],
      initial_amount: response['initial_amount'],
      standing_amount: response['standing_amount'],
      payment_reference: response['payment_reference'],
      payment_link: response['payment_link'],
      api_username: response['api_username'],
      warnings: response['warnings'],
      stan: response['stan'],
      fraud_score: response['fraud_score'],
      payment_state: response['payment_state'],
      payment_method: response['payment_method'],
      ob_details: response['ob_details'],
      creditor_iban: response['creditor_iban'],
      ob_payment_reference: response['ob_payment_reference'],
      ob_payment_state: response['ob_payment_state'],
      transaction_time: response['transaction_time']
    }
  end
end
