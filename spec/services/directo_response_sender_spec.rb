require 'rails_helper'

RSpec.describe 'DirectoResponseSender' do
  xml_data = <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
    <results>
      <Result Type="0" Desc="OK" docid="#{@invoice_id}" doctype="ARVE" submit="Invoices"/>
    </results>
  XML

  directo_json_response = {
    this_is: 'response'
  }

  service_message = {
    message: 'everything okey'
  }

  before(:each) do
    stub_request(:put, "http://registry:3000/eis_billing/directo_response")
    .to_return(status: 200, body: service_message.to_json, headers: {})

    stub_request(:put, "http://auction_center:3000/eis_billing/directo_response")
    .to_return(status: 200, body: service_message.to_json, headers: {})

    stub_request(:put, "http://eeid:3000/eis_billing/directo_response")
    .to_return(status: 200, body: service_message.to_json, headers: {})
  end

  describe 'generate url' do
    it 'if initiator registry, then it should return registry endpoin' do
      results = DirectoResponseSender.send_request(response: directo_json_response,
                                                   xml_data: xml_data,
                                                   initiator: 'registry')

      expect(results["message"]).to eq("everything okey")
    end

    it 'if initiator auction, then it should return auction endpoin' do
      results = DirectoResponseSender.send_request(response: directo_json_response,
                                                   xml_data: xml_data,
                                                   initiator: 'auction')

      expect(results["message"]).to eq("everything okey")
    end

    it 'if initiator eeid, then it should return eeid endpoin' do
      results = DirectoResponseSender.send_request(response: directo_json_response,
                                                   xml_data: xml_data,
                                                   initiator: 'eeid')

      expect(results["message"]).to eq("everything okey")
    end
  end
end
