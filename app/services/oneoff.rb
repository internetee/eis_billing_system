class InvalidParams < StandardError; end

class Oneoff
  include Request
  include ApplicationService

  attr_reader :invoice_number, :customer_url, :reference_number, :bulk, :bulk_invoices

  def initialize(invoice_number:, customer_url:, reference_number:, bulk: false, bulk_invoices: [])
    @invoice = Invoice.find_by(invoice_number:)

    @invoice_number = invoice_number
    @customer_url = customer_url
    @reference_number = reference_number
    @bulk = bulk
    @bulk_invoices = bulk_invoices
  end

  def self.call(invoice_number:, customer_url:, reference_number:, bulk: false, bulk_invoices: [])
    new(invoice_number:,
        customer_url:,
        reference_number:,
        bulk:,
        bulk_invoices:).call
  end

  # rubocop:disable Metrics/MethodLength
  def call
    if @invoice.nil?
      errors = if invoice_number.nil?
                 'Internal error: called invoice withour number. Please contact to administrator'
               else
                 "Invoice with #{invoice_number} not found in internal system"
               end

      return wrap(result: false, instance: nil, errors:)
    end

    contract = OneoffParamsContract.new
    result = contract.call(invoice_number:,
                           customer_url:,
                           reference_number:)
    if result.success?
      response = base_request
      struct_response(response)
    else
      parse_validation_errors(result)
    end
  end

  private

  def base_request
    uri = URI("#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
    post(direction: 'everypay', path: uri, params: body)
  end

  # rubocop:disable Metrics/AbcSize
  def body
    bulk_description = "Ref:#{@invoice.invoice_number}, #{bulk_invoices.join(', ')}"
    {
      'api_username' => GlobalVariable::API_USERNAME,
      'account_name' => GlobalVariable::ACCOUNT_NAME,
      'amount' => @invoice.transaction_amount.to_f,
      'order_reference' => bulk ? bulk_description.to_s : @invoice.invoice_number.to_s,
      # 'token_agreement' => 'unscheduled',
      'request_token' => false,
      'nonce' => "#{rand(10**30).to_s.rjust(30, '0')}",
      'timestamp' => "#{Time.zone.now.to_formatted_s(:iso8601)}",
      'customer_url' => customer_url,
      'preferred_country' => 'EE',
      'locale' => 'en',
      'structured_reference' => reference_number.to_s,
      'mobile_payment' => true
    }
  end
end
