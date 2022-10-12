class InvalidParams < StandardError; end

class Oneoff
  include Request
  include ServiceApplication

  attr_reader :invoice_number, :customer_url, :reference_number

  def initialize(invoice_number:, customer_url:, reference_number:)
    @invoice = Invoice.find_by(invoice_number: invoice_number)
    @customer_url = customer_url
    @reference_number = reference_number
  end

  def self.call(invoice_number:, customer_url:, reference_number: nil)
    contract = OneoffParamsContract.new
    result = contract.call(invoice_number: invoice_number,
                           customer_url: customer_url,
                           reference_number: reference_number)
    service = new(invoice_number: invoice_number, customer_url: customer_url, reference_number: reference_number)

    if result.success?
      response = service.base_request
      service.parse_response(response)
    else
      service.parse_validation_errors(result)
    end
  end

  def base_request
    uri = URI("#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
    post(direction: 'everypay', path: uri, params: body)
  end

  private

  def body
    {
      'api_username' => GlobalVariable::API_USERNAME,
      'account_name' => GlobalVariable::ACCOUNT_NAME,
      'amount' => @invoice.transaction_amount.to_f,
      'order_reference' => "#{@invoice.invoice_number}",
      'token_agreement' => 'unscheduled',
      'nonce' => "#{rand(10 ** 30).to_s.rjust(30,'0')}",
      'timestamp' => "#{Time.zone.now.to_formatted_s(:iso8601)}",
      'email' => Setting.registry_email,
      # 'customer_ip' => '1.2.3.4',
      'customer_url' => customer_url,
      'preferred_country' => 'EE',
      'billing_city' => Setting.registry_city,
      'billing_country' => Setting.registry_country_code,
      'billing_line1' => Setting.registry_street,
      # 'billing_line2' => 'Building 3',
      # 'billing_line3' => 'Room 11',
      'billing_postcode' => Setting.registry_zip,
      'billing_state' => Setting.registry_state,
      'locale' => 'en',
      'request_token' => true,
      'structured_reference' => reference_number.to_s
      # 'payment_description' => "Reference number: 1233321"
    }
  end
end
