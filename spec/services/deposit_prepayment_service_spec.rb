require 'rails_helper'

RSpec.describe 'DepositPrepaymentService' do
  describe 'call' do
    let(:invoice_params) do
      {
        initiator: 'auction',
        transaction_amount: '50.0',
        customer_url: "#{GlobalVariable::BASE_AUCTION}/test",
        custom_field2: 'auction',
        description: 'description'
      }
    end

    let(:failed_params) do
      {
        error: {
          message: 'Something went wrong'
        }
      }
    end

    let(:oneoff) do
      {
        payment_link: 'https://one.off'
      }
    end

    context 'Success' do
      before(:each) do
        stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
          .to_return(status: 201, body: oneoff.to_json, headers: {})
      end

      it 'should return worked payment link' do
        response = DepositPrepaymentService.call(params: invoice_params)
        expect(response.instance['payment_link']).to eq 'https://one.off'
      end

      it 'if payment was successfully generated should be true result' do
        response = DepositPrepaymentService.call(params: invoice_params)
        expect(response.result?).to be_truthy
      end
    end

    context 'Failed' do
      before(:each) do
        stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
          .to_return(status: 201, body: failed_params.to_json, headers: {})
      end

      it 'if some errors occured should return false of result' do
        response = DepositPrepaymentService.call(params: invoice_params)
        expect(response.result?).to be_falsey
      end

      it 'it some errors should return error test' do
        response = DepositPrepaymentService.call(params: invoice_params)
        expect(response.errors).to include(
          failed_params.to_json['message']
        )
      end
    end
  end
end
