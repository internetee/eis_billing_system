class DirectoResponseSender
  include Request

  attr_reader :response, :xml_data, :initiator, :monthly

  DIRECTO_SERVICE_ENDPOINT = '/eis_billing/directo_response'.freeze

  def initialize(response:, xml_data:, initiator:)
    @response = response
    @xml_data = xml_data
    @initiator = initiator
    @monthly = monthly
  end

  def self.send_request(response:, xml_data:, initiator:)
    fetcher = new(response: response, xml_data: xml_data, initiator: initiator)
    fetcher.base_request
  end

  def base_request
    response_data = {
      response: response,
      xml_data: xml_data,
    }

    Rails.logger.info "Sanding directo response data: #{response_data.to_json}"

    url = directo_response_url[@initiator.to_sym]
    put_request(direction: 'services', path: url, params: response_data)
  end

  private

  def directo_response_url
    {
      registry: "#{GlobalVariable::BASE_REGISTRY}#{DIRECTO_SERVICE_ENDPOINT}",
      auction: "#{GlobalVariable::BASE_AUCTION}#{DIRECTO_SERVICE_ENDPOINT}",
      eeid: "#{GlobalVariable::BASE_EEID}#{DIRECTO_SERVICE_ENDPOINT}",
    }
  end
end
