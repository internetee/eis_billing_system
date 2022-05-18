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

  describe 'generate url' do
    it 'if initiator registry, then it should return registry endpoin' do
      stub_const('ENV', { 'base_registry' => 'registry' })

      class MockHttp
        def put(one, two, three)
          "everything okey"
        end
      end

      allow(Base).to receive(:generate_http_request_sender).with(url: 'registry/eis_billing/directo_response').and_return(MockHttp.new)
      allow(Base).to receive(:generate_headers).and_return({header: 'header'})

      results = DirectoResponseSender.send_request(response: directo_json_response, xml_data: xml_data, initiator: 'registry')

      expect(results).to eq("everything okey")
    end

    it 'if initiator auction, then it should return auction endpoin' do
      stub_const('ENV', { 'base_auction' => 'auction' })

      class MockHttp
        def put(one, two, three)
          "everything okey"
        end
      end

      allow(Base).to receive(:generate_http_request_sender).with(url: 'auction/eis_billing/directo_response').and_return(MockHttp.new)
      allow(Base).to receive(:generate_headers).and_return({header: 'header'})

      results = DirectoResponseSender.send_request(response: directo_json_response, xml_data: xml_data, initiator: 'auction')

      expect(results).to eq("everything okey")
    end

    it 'if initiator eeid, then it should return eeid endpoin' do
      stub_const('ENV', { 'base_eeid' => 'eeid' })

      class MockHttp
        def put(one, two, three)
          "everything okey"
        end
      end

      allow(Base).to receive(:generate_http_request_sender).with(url: 'eeid/eis_billing/directo_response').and_return(MockHttp.new)
      allow(Base).to receive(:generate_headers).and_return({header: 'header'})

      results = DirectoResponseSender.send_request(response: directo_json_response, xml_data: xml_data, initiator: 'eeid')

      expect(results).to eq("everything okey")
    end
  end
end
