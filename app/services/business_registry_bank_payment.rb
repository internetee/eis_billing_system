class BusinessRegistryBankPayment
  include Request

  CURRENCY = 'EUR'.freeze

  attr_reader :reference, :transactions

  def initialize(reference:, transactions:)
    @reference = reference
    @transactions = transactions
  end

  def self.call(reference:, transactions:)
    new(reference:, transactions:).call
  end

  def call
    transactions.each { |transaction| process(transaction) }
  end

  private

  def process(transaction)
    invoice = Invoice.find_by(reference_number: reference.reference_number, initiator: Invoice::BUSINESS_REGISTRY)

    return inform_admin('Business registry invoice not found', transaction) if invoice.nil?
    return inform_admin('Business registry invoice already paid', transaction, invoice) if invoice.paid?
    return inform_admin('Business registry payment mismatch', transaction, invoice) unless matches?(invoice, transaction)

    invoice.update!(status: :paid, transaction_time: transaction.date)
    notify_registry(invoice, transaction)
  end

  def matches?(invoice, transaction)
    transaction.currency.to_s == CURRENCY &&
      BigDecimal(transaction.amount.to_s) == invoice.transaction_amount
  end

  def notify_registry(invoice, transaction)
    response = connection(options: service_options)
               .put(GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL, JSON.dump(payment_params(invoice, transaction)))
    return if response.status == 200

    inform_admin("Registry rejected business registry payment with status #{response.status}",
                 transaction, invoice, response.body)
  rescue Faraday::Error => e
    inform_admin('Registry is unavailable for business registry payment', transaction, invoice, e.message)
  end

  def payment_params(invoice, transaction)
    {
      reference_number: invoice.reference_number,
      invoice_number: invoice.invoice_number.to_s,
      amount: invoice.transaction_amount.to_s,
      currency: CURRENCY,
      paid_at: transaction.date.to_date.iso8601
    }
  end

  def inform_admin(title, transaction, invoice = nil, details = nil)
    message = "Reference number: #{reference.reference_number}; " \
              "invoice number: #{invoice&.invoice_number}; invoice status: #{invoice&.status}; " \
              "amount: #{transaction.amount} #{transaction.currency}; date: #{transaction.date}; " \
              "description: #{transaction.payment_description}; details: #{details}"

    Rails.logger.info "#{title}. #{message}"
    NotifierMailer.inform_admin(title, message).deliver_now
  end
end
