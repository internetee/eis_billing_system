class DirectoResponseSender < Base
  def self.send_request(response:, xml_data:, initiator:)
    @initiator = initiator
    Rails.logger.info "BREAKPOINT"
    base_request(response: response, xml_data: xml_data)
  end

  def self.base_request(response:, xml_data:)
    response_data = {
      response: response,
      xml_data: xml_data
    }

    Rails.logger.info "Sanding directo response data: #{response_data.to_json}"

    url = get_endpoint_services_directo_url[@initiator.to_sym]
    http = generate_http_request_sender(url: url)
    # http.use_ssl = true unless Rails.env.development?
    http.put(url, response_data.to_json, generate_headers)
  end

  def self.get_endpoint_services_directo_url
    {
      registry: "#{ENV['base_registry']}/eis_billing/directo_response",
      auction: "#{ENV['base_auction']}/eis_billing/directo_response",
      eeid: "#{ENV['base_eeid']}/eis_billing/directo_response"
    }
  end
end
