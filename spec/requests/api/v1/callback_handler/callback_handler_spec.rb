require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true)
  end

  let(:invoice) { create(:invoice) }

  context "successful callback process" do
    it "should return ok status" do
      payment_reference = "test_code"

      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: invoice.invoice_number,
        payment_reference: payment_reference,
      }
      response_message = {
        message: 'received'
      }
      
      everypay_url = "#{GlobalVariable::BASE_ENDPOINT}/payments/#{payment_reference}?api_username=#{GlobalVariable::API_USERNAME}"

      stub_request(:get, everypay_url).to_return(status: 200, body: everypay_response.to_json, headers: {})
      stub_request(:put, "http://registry:3000/eis_billing/payment_status")
      .to_return(status: 200, body: response_message.to_json, headers: {})

      get api_v1_callback_handler_callback_path + "?payment_reference=#{payment_reference}"

      expect(response.code).to eq "200"
    end
  end
end
