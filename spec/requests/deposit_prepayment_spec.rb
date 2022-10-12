require 'rails_helper'

RSpec.describe 'DepositPrepaymentController', type: :request do
  describe '/api/v1/invoice_generator/deposit_prepayment' do
    before(:each) do
      expect_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
    end

    context 'successful case' do
      let(:invoice_params) do
        {
          initiator: 'auction',
          transaction_amount: '50.0',
          customer_url: "#{GlobalVariable::BASE_AUCTION}/test",
          custom_field2: 'auction',
          description: 'description'
        }
      end

      let(:oneoff) do
        {
          payment_link: 'https://one.off'
        }
      end

      it 'should successfully create deposit prepayment' do
        stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
          .to_return(status: 201, body: oneoff.to_json, headers: {})

        post '/api/v1/invoice_generator/deposit_prepayment', headers: {}, params: invoice_params
        expect(response.status).to eq 201
        expect(JSON.parse(response.body)['oneoff_redirect_link']).to eq 'https://one.off'
      end

      it 'should generate new invoices' do
        stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
          .to_return(status: 201, body: oneoff.to_json, headers: {})

        expect { post '/api/v1/invoice_generator/deposit_prepayment', headers: {}, params: invoice_params }.to change {
                                                                                                                 Invoice.count
                                                                                                               }.by(1)
      end
    end
  end
end
