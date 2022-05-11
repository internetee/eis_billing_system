class DirectoResponseSender < Base
  attr_reader :response, :xml_data, :initiator

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
    http = Base.generate_http_request_sender(url: url)
    # http.use_ssl = true unless Rails.env.development?
    http.put(url, response_data.to_json, Base.generate_headers)
  end

  private

  def get_endpoint_services_directo_url
    {
      registry: "#{ENV['base_registry']}/eis_billing/directo_response",
      auction: "#{ENV['base_auction']}/eis_billing/directo_response",
      eeid: "#{ENV['base_eeid']}/eis_billing/directo_response"
    }
  end
end
