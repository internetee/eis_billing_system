require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  let(:valid_params) do
    {
      invoice_number: "125",
      custom_field2: "registry",
      transaction_amount: "23.30",
      reference_number: "REF123",
      order_reference: "Order 123",
      customer_name: "John Doe",
      customer_email: "john@example.com",
      custom_field_1: "Invoice description",
      linkpay_token: "token123"
    }
  end

  before(:each) do
    allow_any_instance_of(Api::V1::InvoiceGenerator::InvoiceGeneratorController).to receive(:logged_in?).and_return(true)
    allow(InvoiceInstanceGenerator).to receive(:create)
    allow(EverypayLinkGenerator).to receive(:create).and_return('http://everypay.link')
  end

  describe "POST /create" do
    it "should return success" do
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
      expect(response).to have_http_status(:created)
    end

    it "should call InvoiceInstanceGenerator with correct parameters" do
      expect(InvoiceInstanceGenerator).to receive(:create).with(params: instance_of(ActionController::Parameters))
      
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
    end

    it "should call EverypayLinkGenerator with correct parameters" do
      expect(EverypayLinkGenerator).to receive(:create).with(params: instance_of(ActionController::Parameters))
      
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
    end

    it "should return correct JSON response" do
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
      
      expect(response.content_type).to include("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Link created')
      expect(json_response['everypay_link']).to eq('http://everypay.link')
    end

    it "should handle InvoiceInstanceGenerator errors" do
      allow(InvoiceInstanceGenerator).to receive(:create).and_raise(StandardError.new("Invoice error"))
      
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
      
      expect(response).to have_http_status(:no_content)
    end

    it "should handle EverypayLinkGenerator errors" do
      allow(EverypayLinkGenerator).to receive(:create).and_raise(StandardError.new("Link error"))
      
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
      
      expect(response).to have_http_status(:no_content)
    end

    it "should log errors" do
      allow(Rails.logger).to receive(:info)
      allow(InvoiceInstanceGenerator).to receive(:create).and_raise(StandardError.new("Test error"))
      
      post api_v1_invoice_generator_invoice_generator_index_path, params: valid_params
      
      expect(Rails.logger).to have_received(:info).with(instance_of(StandardError))
    end

    context "with missing required parameters" do
      let(:invalid_params) { { invoice_number: "125" } }

      it "should still process request" do
        post api_v1_invoice_generator_invoice_generator_index_path, params: invalid_params
        expect(response).to have_http_status(:created)
      end
    end

    context "with different initiator values" do
      it "should handle registry initiator" do
        params = valid_params.merge(custom_field2: "registry")
        post api_v1_invoice_generator_invoice_generator_index_path, params: params
        expect(response).to have_http_status(:created)
      end

      it "should handle eeid initiator" do
        params = valid_params.merge(custom_field2: "eeid")
        post api_v1_invoice_generator_invoice_generator_index_path, params: params
        expect(response).to have_http_status(:created)
      end

      it "should handle auction initiator" do
        params = valid_params.merge(custom_field2: "auction")
        post api_v1_invoice_generator_invoice_generator_index_path, params: params
        expect(response).to have_http_status(:created)
      end
    end
  end
end