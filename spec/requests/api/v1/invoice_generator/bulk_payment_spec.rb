require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::BulkPaymentController", type: :request do
  let(:valid_params) do
    {
      custom_field2: "auction",
      customer_url: "https://example.com/callback",
      description: "Bulk payment description",
      transaction_amount: "100.00"
    }
  end

  let(:successful_response) do
    double('response', result?: true, instance: { 'payment_link' => 'https://payment.link' })
  end

  let(:failed_response) do
    double('response', result?: false, errors: { error: 'Payment failed' })
  end

  before(:each) do
    allow_any_instance_of(Api::V1::InvoiceGenerator::BulkPaymentController).to receive(:logged_in?).and_return(true)
    allow(Auction::BulkPaymentService).to receive(:call).and_return(successful_response)
  end

  describe "POST /create" do
    it "should return success when payment service succeeds" do
      post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params
      expect(response).to have_http_status(:created)
    end

    it "should call Auction::BulkPaymentService with correct parameters" do
      expect(Auction::BulkPaymentService).to receive(:call).with(params: hash_including("custom_field2" => "auction", "transaction_amount" => "100.00"))
      
      post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params
    end

    it "should return correct JSON response on success" do
      post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params
      
      expect(response.content_type).to include("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response['message']).to eq('Link created')
      expect(json_response['oneoff_redirect_link']).to eq('https://payment.link')
    end

    it "should handle service failure" do
      allow(Auction::BulkPaymentService).to receive(:call).and_return(failed_response)
      
      post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params
      
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "should return error JSON on failure" do
      allow(Auction::BulkPaymentService).to receive(:call).and_return(failed_response)
      
      post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params
      
      expect(response.content_type).to include("application/json")
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq({ 'error' => 'Payment failed' })
    end

    context "with different initiator values" do
      %w[auction registry eeid].each do |initiator|
        it "returns :created for initiator #{initiator}" do
          post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params.merge(custom_field2: initiator)
          expect(response).to have_http_status(:created)
        end
      end
    end

    context "with missing required parameters" do
      let(:invalid_params) { { custom_field2: "auction" } }

      it "should still process request" do
        post api_v1_invoice_generator_bulk_payment_index_path, params: invalid_params
        expect(response).to have_http_status(:created)
      end
    end

    context "with different transaction amounts" do
      %w[99.99 10000.00].each do |amount|
        it "returns :created for amount #{amount}" do
          post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params.merge(transaction_amount: amount)
          expect(response).to have_http_status(:created)
        end
      end
    end

    context "with different customer URLs" do
      [
        "https://secure.example.com/callback",
        "http://example.com/callback"
      ].each do |url|
        it "returns :created for URL #{url[0..20]}..." do
          post api_v1_invoice_generator_bulk_payment_index_path, params: valid_params.merge(customer_url: url)
          expect(response).to have_http_status(:created)
        end
      end
    end
  end
end
