class EverypayResponse < Base
  KEY = ENV['everypay_key']
  LINKPAY_PREFIX = ENV['linkpay_prefix'] || 'https://igw-demo.every-pay.com/lp'
  LINKPAY_TOKEN = ENV['linkpay_token']
  API_USERNAME = ENV['api_username']

  attr_reader :payment_reference

  def initialize(payment_reference)
    @payment_reference = payment_reference
  end

  def self.send_request(payment_reference)
    fetcher = new(payment_reference)

    url = fetcher.generate_url(payment_reference: payment_reference, api_username: API_USERNAME)
    fetcher.base_request(url: url, api_username: API_USERNAME, api_secret: KEY)
  end

  def generate_url(payment_reference:, api_username:)
    "https://igw-demo.every-pay.com/api/v4/payments/#{payment_reference}?api_username=#{api_username}"
  end

  def base_request(url:, api_username:, api_secret:)
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
