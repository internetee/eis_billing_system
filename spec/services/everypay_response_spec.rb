require 'rails_helper'

RSpec.describe EverypayResponse do
  let(:payment_reference) { "test_payment_ref_123" }
  
  describe ".call" do
    it "should exist as a class method" do
      expect(EverypayResponse).to respond_to(:call)
    end

    it "should accept payment_reference as parameter" do
      service = instance_double(EverypayResponse)
      allow(EverypayResponse).to receive(:new).and_return(service)
      allow(service).to receive(:generate_url).and_return("http://test.com")
      allow(service).to receive(:base_request).and_return({ status: 200 })
      
      expect { EverypayResponse.call(payment_reference) }.not_to raise_error
    end
  end

  describe "#generate_url" do
    it "should return URL with payment reference" do
      service = EverypayResponse.new(payment_reference)
      url = service.generate_url(payment_reference: payment_reference)
      
      expect(url).to be_present
      expect(url).to include("payments/#{payment_reference}")
      expect(url).to include("api_username=#{GlobalVariable::API_USERNAME}")
    end
  end

  describe '#base_request' do
    it 'delegates to get with everypay direction' do
      instance = described_class.new(payment_reference)
      uri = instance.generate_url(payment_reference: payment_reference)
      allow(instance).to receive(:get).and_return({ 'ok' => true })
      result = instance.base_request(uri: uri)
      expect(instance).to have_received(:get).with(direction: 'everypay', path: uri)
      expect(result).to eq({ 'ok' => true })
    end
  end
end
