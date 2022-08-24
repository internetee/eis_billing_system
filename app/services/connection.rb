require 'faraday'
require 'faraday/net_http'
Faraday.default_adapter = :net_http

module Connection
  INITIATOR = 'billing'.freeze

  API_USERNAME = 'ca8d6336dd750ddb'
  KEY = 'c05fa8dae730cc0cf57fe445861953fa'
  BASE_ENDPOINT = 'https://igw-demo.every-pay.com/api/v4'
  ONEOFF_ENDPOINT = '/payments/oneoff'
  ACCOUNT_NAME = 'EUR3D1'

  def connection
    Faraday.new(options) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end

  private

  def options
    {
      headers: {
        'Authorization' => "Bearer #{generate_token}",
        'Content-Type' => 'application/json',
      }
    }
  end

  def generate_token
    JWT.encode(payload, billing_secret)
  end

  def payload
    { initiator: INITIATOR }
  end

  def billing_secret
    ENV['billing_secret']
  end
end

