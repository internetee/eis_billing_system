require 'faraday'
require 'faraday/net_http'
Faraday.default_adapter = :net_http

module Connection
  def connection(options:)
    Faraday.new(options) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end
end

