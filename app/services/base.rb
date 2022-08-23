class Base
  INITIATOR = 'billing'.freeze

  API_USERNAME = 'ca8d6336dd750ddb'
  KEY = 'c05fa8dae730cc0cf57fe445861953fa'
  BASE_ENDPOINT = 'https://igw-demo.every-pay.com/api/v4'
  ONEOFF_ENDPOINT = '/payments/oneoff'
  ACCOUNT_NAME = 'EUR3D1'

  def self.generate_http_request_sender(url:)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)

    unless Rails.env.development? || Rails.env.test?
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http
  end

  def self.generate_token
    JWT.encode(payload, billing_secret)
  end

  def self.payload
    { initiator: INITIATOR }
  end

  def self.generate_headers
    {
      'Authorization' => "Bearer #{generate_token}",
      'Content-Type' => 'application/json'
    }
  end

  def self.billing_secret
    ENV['billing_secret']
  end
end
