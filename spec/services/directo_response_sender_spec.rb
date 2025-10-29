require 'rails_helper'

RSpec.describe DirectoResponseSender do
  let(:response_data) { { status: 'success', message: 'Invoice processed' } }
  let(:xml_data) { '<xml><invoice>test</invoice></xml>' }
  let(:initiator) { 'registry' }

  describe '.send_request' do
    it 'creates instance and calls base_request' do
      sender = instance_double(described_class)
      allow(described_class).to receive(:new).and_return(sender)
      allow(sender).to receive(:base_request).and_return({ success: true })

      result = described_class.send_request(
        response: response_data,
        xml_data: xml_data,
        initiator: initiator
      )

      expect(described_class).to have_received(:new).with(
        response: response_data,
        xml_data: xml_data,
        initiator: initiator
      )
      expect(sender).to have_received(:base_request)
      expect(result).to eq({ success: true })
    end
  end

  describe '#base_request' do
    let(:sender) { described_class.new(response: response_data, xml_data: xml_data, initiator: initiator) }

    before do
      allow(sender).to receive(:put_request).and_return({ success: true })
    end

    it 'sends request to correct registry endpoint' do
      sender.base_request

      expect(sender).to have_received(:put_request).with(
        direction: 'services',
        path: "#{GlobalVariable::BASE_REGISTRY}/eis_billing/directo_response",
        params: {
          response: response_data,
          xml_data: xml_data
        }
      )
    end

    it 'sends request to correct auction endpoint' do
      auction_sender = described_class.new(response: response_data, xml_data: xml_data, initiator: 'auction')
      allow(auction_sender).to receive(:put_request).and_return({ success: true })

      auction_sender.base_request

      expect(auction_sender).to have_received(:put_request).with(
        direction: 'services',
        path: "#{GlobalVariable::BASE_AUCTION}/eis_billing/directo_response",
        params: {
          response: response_data,
          xml_data: xml_data
        }
      )
    end

    it 'sends request to correct eeid endpoint' do
      eeid_sender = described_class.new(response: response_data, xml_data: xml_data, initiator: 'eeid')
      allow(eeid_sender).to receive(:put_request).and_return({ success: true })

      eeid_sender.base_request

      expect(eeid_sender).to have_received(:put_request).with(
        direction: 'services',
        path: "#{GlobalVariable::BASE_EEID}/eis_billing/directo_response",
        params: {
          response: response_data,
          xml_data: xml_data
        }
      )
    end

    it 'logs the request data' do
      allow(Rails.logger).to receive(:info)

      sender.base_request

      expect(Rails.logger).to have_received(:info).with(
        "Sanding directo response data: #{{
          response: response_data,
          xml_data: xml_data
        }.to_json}"
      )
    end
  end

  describe '#directo_response_url' do
    let(:sender) { described_class.new(response: response_data, xml_data: xml_data, initiator: initiator) }

    it 'returns correct URLs for all initiators' do
      urls = sender.send(:directo_response_url)

      expect(urls[:registry]).to eq("#{GlobalVariable::BASE_REGISTRY}/eis_billing/directo_response")
      expect(urls[:auction]).to eq("#{GlobalVariable::BASE_AUCTION}/eis_billing/directo_response")
      expect(urls[:eeid]).to eq("#{GlobalVariable::BASE_EEID}/eis_billing/directo_response")
    end
  end

  describe 'error handling' do
    let(:sender) { described_class.new(response: response_data, xml_data: xml_data, initiator: initiator) }

    it 'handles network errors gracefully' do
      allow(sender).to receive(:put_request).and_raise(StandardError.new('Network error'))

      expect { sender.base_request }.to raise_error(StandardError, 'Network error')
    end

    it 'handles invalid initiator' do
      invalid_sender = described_class.new(response: response_data, xml_data: xml_data, initiator: 'invalid')
      allow(invalid_sender).to receive(:put_request).and_raise(NoMethodError)

      expect { invalid_sender.base_request }.to raise_error(NoMethodError)
    end
  end

  describe 'integration with Request module' do
    let(:sender) { described_class.new(response: response_data, xml_data: xml_data, initiator: initiator) }

    it 'includes Request module functionality' do
      expect(sender.class.ancestors).to include(Request)
    end

    it 'uses service options for authentication' do
      allow(sender).to receive(:put_request).and_return({ success: true })

      sender.base_request

      expect(sender).to have_received(:put_request).with(
        direction: 'services',
        path: anything,
        params: anything
      )
    end
  end
end