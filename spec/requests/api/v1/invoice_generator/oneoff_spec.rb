require 'rails_helper'

RSpec.describe Api::V1::InvoiceGenerator::OneoffController, type: :request do
  let(:invoice) { create(:invoice) }
  let(:customer_url_registry) { GlobalVariable::BASE_REGISTRY }
  let(:customer_url_registrar) { GlobalVariable::BASE_REGISTRAR }
  let(:customer_url_eeid) { GlobalVariable::BASE_EEID }
  let(:customer_url_auction) { GlobalVariable::BASE_AUCTION }
  let(:reference) { create(:reference) }

  before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

  describe "successfully case" do
    payment_link = { 'payment_link' => 'https://everypay.ee' }

    before(:each) do
      stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
        .to_return(status: 200, body: payment_link.to_json, headers: {})
    end

    it 'should return the payment link if intiiator is eeid' do
      payload = {
        invoice_number: invoice.invoice_number,
        customer_url: customer_url_eeid,
        reference_number: nil,
      }

      post api_v1_invoice_generator_oneoff_index_path, params: payload, headers: {}
      expect(JSON.parse(response.body)['oneoff_redirect_link']).to eq('https://everypay.ee')
    end

    it 'should return the payment link if intiiator is registry' do
      payload = {
        invoice_number: invoice.invoice_number,
        customer_url: customer_url_registry,
        reference_number: reference.reference_number,
      }

      post api_v1_invoice_generator_oneoff_index_path, params: payload, headers: {}
      expect(JSON.parse(response.body)['oneoff_redirect_link']).to eq('https://everypay.ee')
    end

    it 'should return the payment link if intiiator is auction' do
      payload = {
        invoice_number: invoice.invoice_number,
        customer_url: customer_url_auction,
        reference_number: nil,
      }

      post api_v1_invoice_generator_oneoff_index_path, params: payload, headers: {}
      expect(JSON.parse(response.body)['oneoff_redirect_link']).to eq('https://everypay.ee')
    end
  end

  describe "errors" do
    let(:invoice) { create(:invoice) }

    it "shoud return 422 unprocessable_entity status" do
      payload = {
        invoice_number: invoice.invoice_number,
        customer_url: "http://superhack.ee",
        reference_number: nil,
      }

      post api_v1_invoice_generator_oneoff_index_path, params: payload, headers: {}
      expect(response.status).to eq(422)
    end

    it "shoud return error message" do
      payload = {
        invoice_number: invoice.invoice_number,
        customer_url: "http://superhack.ee",
        reference_number: nil,
      }

      post api_v1_invoice_generator_oneoff_index_path, params: payload, headers: {}
      expect(JSON.parse(response.body)['error']).to eq(
        {
          "customer_url" => [I18n.t('api_errors.customer_url_error')]
        }
      )
    end
  end
end
