require 'rails_helper'

RSpec.describe 'Api::V1::ImportData::InvoiceDataController', type: :request do
  describe 'POST /api/v1/import_data/invoice_data' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:billing_secret_key).and_return('test_secret')
    end

    let(:auth_headers) do
      token = JWT.encode({ initiator: 'registry' }, 'test_secret')
      { 'Authorization' => "Bearer #{token}" }
    end

    it 'enqueues/parses payload and returns ok message' do
      payload = [
        { 'invoice_number' => '300', 'initiator' => 'registry', 'transaction_amount' => '10.0', 'status' => 'issued' }
      ]

      post '/api/v1/import_data/invoice_data', params: { _json: payload }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to include('Added')
    end
  end
end


