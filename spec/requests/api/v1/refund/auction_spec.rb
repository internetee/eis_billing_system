require 'rails_helper'

RSpec.describe "Refund::Auction", type: :request do
  let(:invoice) { create(:invoice) }

  before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

  refund_response = {
    'api_username' => 'abc12345',
    'initial_amount' => '2.50',
    'standing_amount' => '1.50',
    'transaction_time' => '2015-04-02T07:53:07Z',
    'payment_reference' => 'db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a',
    'payment_state' => 'refunded'
  }

  refund_failed = {
    "error": {
        "code": 4997,
        "message": "The timestamp is not valid"
    }
  }

  open_bank_not_support_refund =
    {
        "error": {
            "code": 4037,
            "message": "Open banking payments cannot be refunded"
        }
    }

  it 'should return ok response' do
    stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
    .to_return(status: 200, body: refund_response.to_json, headers: {})

    invoice.reload

    post api_v1_refund_auction_index_path, params: { invoice_id: invoice.id }

    expect(response.status).to eq 200
    expect(JSON.parse(response.body)['message']).to eq 'Invoice was refunded'
  end

  it 'invoice not exists' do
    post api_v1_refund_auction_index_path, params: { invoice_id: 'invalid' }

    expect(response.status).to eq 404
    expect(JSON.parse(response.body)['error']).to eq 'Invoice not found'
  end

  it 'open bank not supported refund' do
    stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
      .to_return(status: 200, body: open_bank_not_support_refund.to_json, headers: {})

    invoice.reload

    post api_v1_refund_auction_index_path, params: { invoice_id: invoice.id }

    expect(response.status).to eq 422
    expect(JSON.parse(response.body)['error']['message']).to eq 'Open banking payments cannot be refunded'
  end

  it 'arise some error from everypay' do
    stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
    .to_return(status: 200, body: refund_failed.to_json, headers: {})

    invoice.reload

    post api_v1_refund_auction_index_path, params: { invoice_id: invoice.id }

    expect(response.status).to eq 422
    expect(JSON.parse(response.body)['error']['message']).to eq 'The timestamp is not valid'
  end
end
