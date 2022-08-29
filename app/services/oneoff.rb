class Oneoff
  include Request
  attr_reader :invoice_number, :customer_url

  def initialize(invoice_number:, customer_url:)
    @invoice = Invoice.find_by(invoice_number: invoice_number)
    @customer_url = customer_url
  end

  def self.send_request(invoice_number:, customer_url:)
    fetcher = new(invoice_number: invoice_number, customer_url: customer_url)

    fetcher.base_request
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
      'email' => 'user@example.com',
      'customer_ip' => '1.2.3.4',
      'customer_url' => customer_url,
      'preferred_country' => 'EE',
      'billing_city' => 'Tartu',
      'billing_country' => 'EE',
      'billing_line1' => 'Main street 1',
      'billing_line2' => 'Building 3',
      'billing_line3' => 'Room 11',
      'billing_postcode' => '51009',
      'billing_state' => 'EE',
      'locale' => 'en',
      'request_token' => true
    }
  end
end
