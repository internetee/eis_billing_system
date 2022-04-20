require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  before(:each) { ActionMailer::Base.delivery_method = :test }

  let(:invoice) { create(:invoice) }

  response_everypay = {
    account_name: 'EUR',
    order_reference: 1,
    email: 'clien@mail.ee',
    customer_ip: '12.32.12.12',
    customer_url: 'http://eis.ee',
    payment_created_at: Time.zone.now - 10.hours,
    initial_amount: '10.0',
    standing_amount: '10.0',
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

  describe 'error handler' do
    it 'should notify if invoice did not find' do
      response_everypay = {
        order_reference: 'some_random'
      }

      expect { Notify.call(response_everypay) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'should notify if standard error occur' do
      expect { Notify.call(nil) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe 'callback handler' do
    it 'it should received params from everypay and send request' do
      url = api_v1_callback_handler_callback_path + '?payment_reference=test_code'
      everypay_response = {
        everypay: 'success'
      }

      allow(EverypayResponse).to receive(:send_request).and_return(everypay_response)
      allow(Notify).to receive(:call).and_return(true)
      get url

      expect(JSON.parse(response.body)['message']).to eq(true)
    end
  end
end
