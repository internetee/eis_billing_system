require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  # it_behaves_like 'Callback handler'

  describe "GET /callback" do
    it "returns http success" do
      get "/api/v1/callback_handler/callback?payment_reference=888"
      allow_any_instance_of(Api::V1::CallbackHandler::CallbackHandlerController).to receive(:base_request).and_return response_everypay
      expect(response).to have_http_status(:success)
    end
  end

  def response_everypay
    {"nonce"=>"2e2b52df645065fb0785091fc356a6bc", "timestamp"=>"1638448650", "api_username"=>"ca8d6336dd750ddb", "transaction_result"=>"failed", "processing_errors"=>"[{\"code\":4028,\"message\":\"3DS failure due to technical errors\"}]", "linkpay_token"=>"[FILTERED]", "linkpay_reference"=>"b9eVOGeu", "account_id"=>"EUR3D1", "order_reference"=>"1234", "payment_reference"=>"cb655389c4dd285fa8500cdc977017163d456c3a54779cb09990a1adbb05eeee", "fraud_score"=>"0", "stan"=>"", "state_3ds"=>"unknown", "payment_state"=>"failed", "transaction_time"=>"2021-12-02T12:37:30Z", "amount"=>"100.00", "customer_name"=>"oleg_hasjanov", "customer_email"=>"oleg.phenomenon@gmail.com", "invoice_number"=>"0002", "custom_field_1"=>"helllo_guys_yo", "custom_field_2"=>"", "custom_field_3"=>"", "custom_field_4"=>"", "cc_last_four_digits"=>"3438", "cc_year"=>"2024", "cc_month"=>"10", "cc_holder_name"=>"Every Pay", "cc_type"=>"master_card", "cc_issuer"=>"AS LHV Pank", "cc_funding_source"=>"Debit", "cc_cobrand"=>"", "cc_product"=>"MDS  -Debit MasterCard", "cc_issuer_country"=>"EE", "hmac"=>"14762f03cc7d21fefbe145afd1e6586137198d1133df36882d6a695b266957d3"}
  end
end
