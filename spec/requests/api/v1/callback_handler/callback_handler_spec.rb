require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  let(:invoice) { create(:invoice) }

  response_everypay = {
    account_name: 'EUR',
    order_reference: 1,
    email: "clien@mail.ee",
    customer_ip: '12.32.12.12',
    customer_url: 'http://eis.ee',
    payment_created_at: Time.zone.now - 10.hours,
    initial_amount: "10.0",
    standing_amount: "10.0",
    payment_reference: '234343423423423asd',
    payment_link: 'http://everypay.link',
    api_username: 'some-api',
    warnings: [],
    stan: 'stab',
    fraud_score: 'fraud_score',
    payment_state: 'settled',
    payment_method: 'everypay',
    ob_details: 'ob_details',
    creditor_iban: '23323123323123',
    ob_payment_reference: '213123123',
    ob_payment_state: '213123123',
    transaction_time: Time.zone.now - 1.hour
  }

  it_behaves_like 'should notify initiator', response_everypay

  describe "GET /callback" do
    it "should return 200 ok response" do
      allow(Notify).to receive(:call).and_return(true)
      expect_any_instance_of(Api::V1::CallbackHandler::CallbackHandlerController).to receive(:base_request).and_return(JSON.parse(response_everypay.to_json))

      get api_v1_callback_handler_callback_url + '?payment_reference=some'

      expect(response).to have_http_status(:ok)
    end
  end
end
