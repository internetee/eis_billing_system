require 'rails_helper'

RSpec.describe "Everypays", type: :request do
  let(:payment_reference) { "test_payment_ref_123" }
  let(:everypay_response) { "Payment successful" }

  let(:user) { create(:user) }

  before(:each) do
    allow(Current).to receive(:user).and_return(user)
    allow(EverypayResponse).to receive(:call).and_return(everypay_response)
    allow(Notify).to receive(:call)
  end

  describe "GET /index" do
    it "should return success" do
      get everypay_index_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /everypay_data" do
    it "should return success" do
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to have_http_status(:success)
    end

    it "should call EverypayResponse with correct parameters" do
      expect(EverypayResponse).to receive(:call).with(payment_reference)
      
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    end

    it "should call Notify with response" do
      expect(Notify).to receive(:call).with(response: everypay_response)
      
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
    end

    it "should render turbo stream response" do
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      
      expect(response.content_type).to include("text/vnd.turbo-stream.html")
    end

    it "should include response in turbo stream" do
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      
      expect(response.body).to include("Everypay response result")
      expect(response.body).to include(everypay_response)
    end

    it "should handle different response types" do
      different_response = "Payment failed"
      allow(EverypayResponse).to receive(:call).and_return(different_response)
      
      post "/everypay/everypay_data", params: { payment_reference: payment_reference }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      
      expect(response.body).to include(different_response)
    end

    it "should handle missing payment reference" do
      post "/everypay/everypay_data", params: {}, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      expect(response).to have_http_status(:success)
    end
  end

  describe "html_response method" do
    it "should format response correctly" do
      controller = EverypayController.new
      response_text = "Test response"
      
      html = controller.send(:html_response, response_text)
      
      expect(html).to include("<h2 class='mt-3'>Everypay response result</h2>")
      expect(html).to include("<div class='bg-gray-300 p-4 mt-1 mb-3'>")
      expect(html).to include("<code>#{response_text}</code>")
    end
  end
end