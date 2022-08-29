class DirectoResponseSender
  include Request

  attr_reader :response, :xml_data, :initiator
  DIRECTO_SERVICE_ENDPOINT = '/eis_billing/directo_response'.freeze

  def initialize(response:, xml_data:, initiator:)
    @response = response
    @xml_data = xml_data
    @initiator = initiator
  end

  def self.send_request(response:, xml_data:, initiator:)
    fetcher = new(response: response, xml_data: xml_data, initiator: initiator)
    fetcher.base_request
  end

  def base_request
    response_data = {
      response: response,
      xml_data: xml_data
    }

    Rails.logger.info "Sanding directo response data: #{response_data.to_json}"

    url = get_endpoint_services_directo_url[@initiator.to_sym]
    put_request(direction: 'services', path: url, params: response_data)
  end

  private

  def get_endpoint_services_directo_url
    {
      registry: "#{ENV['base_registry']}#{DIRECTO_SERVICE_ENDPOINT}",
      auction: "#{ENV['base_auction']}#{DIRECTO_SERVICE_ENDPOINT}",
      eeid: "#{ENV['base_eeid']}#{DIRECTO_SERVICE_ENDPOINT}"
    }
  end
end
