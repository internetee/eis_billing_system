class Oneoff < Base
  attr_reader :invoice_number, :customer_url

  def initialize(invoice_number:, customer_url:)
    @invoice = Invoice.find_by(invoice_number: invoice_number)
    @customer_url = customer_url
  end

  def self.send_request(invoice_number:, customer_url:)
    fetcher = new(invoice_number: invoice_number, customer_url: customer_url)

    fetcher.base_request(api_username: API_USERNAME, api_secret: KEY)
  end

  def base_request(api_username:, api_secret:)
    uri = URI("#{BASE_ENDPOINT}#{ONEOFF_ENDPOINT}")

    request = Net::HTTP::Post.new uri
    request.basic_auth api_username, api_secret
    request.body = JSON.generate body
    request.content_type = 'application/json'

    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      response = http.request(request)
      response.body
    end
  end

  def body
    {
      'api_username' => API_USERNAME,
      'account_name' => ACCOUNT_NAME,
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
