class InvalidParams < StandardError; end

class Oneoff
  include Request
  include ApplicationService

  attr_reader :invoice_number, :customer_url, :reference_number, :bulk, :bulk_invoices

  def initialize(invoice_number:, customer_url:, reference_number:, bulk: false, bulk_invoices: [])
    @invoice = Invoice.find_by(invoice_number: invoice_number)

    @invoice_number = invoice_number
    @customer_url = customer_url
    @reference_number = reference_number
    @bulk = bulk
    @bulk_invoices = bulk_invoices
  end

  def self.call(invoice_number:, customer_url:, reference_number:, bulk: false, bulk_invoices: [])
    new(invoice_number: invoice_number,
        customer_url: customer_url,
        reference_number: reference_number,
        bulk: bulk,
        bulk_invoices: bulk_invoices).call
  end

  def call
    if @invoice.nil?
      if invoice_number.nil?
        errors = 'Internal error: called invoice withour number. Please contact to administrator'
      else
        errors = "Invoice with #{invoice_number} not found in internal system"
      end

      return wrap(result: false, instance: nil, errors: errors)
    end

    contract = OneoffParamsContract.new
    result = contract.call(invoice_number: invoice_number,
                           customer_url: customer_url,
                           reference_number: reference_number)
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

  def body
    bulk_description = "Ref:#{@invoice.invoice_number}, #{bulk_invoices.join(', ')}"

    {
      'api_username' => GlobalVariable::API_USERNAME,
      'account_name' => GlobalVariable::ACCOUNT_NAME,
      'amount' => @invoice.transaction_amount.to_f,
      'order_reference' => "#{ bulk ? bulk_description : @invoice.invoice_number }",
      'token_agreement' => 'unscheduled',
      'nonce' => "#{rand(10 ** 30).to_s.rjust(30,'0')}",
      'timestamp' => "#{Time.zone.now.to_formatted_s(:iso8601)}",
      # 'email' => Setting.registry_email,
      'customer_url' => customer_url,
      'preferred_country' => 'EE',
      # 'billing_city' => Setting.registry_city,
      # 'billing_country' => Setting.registry_country_code,
      # 'billing_line1' => Setting.registry_street,
      # 'billing_postcode' => Setting.registry_zip,
      # 'billing_state' => Setting.registry_state,
      'locale' => 'en',
      'request_token' => true,
      'structured_reference' => reference_number.to_s
    }
  end
end