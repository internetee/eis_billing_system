class EverypayResponse < Base
  KEY = ENV['everypay_key']
  LINKPAY_PREFIX = ENV['linkpay_prefix'] || 'https://igw-demo.every-pay.com/lp'
  LINKPAY_TOKEN = ENV['linkpay_token']
  # LINKPAY_QR = true // Maybe useful in future
  API_USERNAME = ENV['api_username']

  def self.send_request(payment_reference)
    # base_request(invoice_number: invoice_number)
    url = generate_url(payment_reference: payment_reference, api_username: API_USERNAME)
    base_request(url: url, api_username: API_USERNAME, api_secret: KEY)
  end

  def self.generate_url(payment_reference:, api_username:)
    "https://igw-demo.every-pay.com/api/v4/payments/#{payment_reference}?api_username=#{api_username}"
  end

  def self.base_request(url:, api_username:, api_secret:)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth api_username, api_secret

      response = http.request request

      return JSON.parse(response.body)
    end
  end
end
