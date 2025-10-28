require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::OneoffController', type: :request do
  describe 'POST /api/v1/invoice_generator/oneoff' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:billing_secret_key).and_return('test_secret')
    end

    let(:auth_headers) do
      token = JWT.encode({ initiator: 'registry' }, 'test_secret')
      { 'Authorization' => "Bearer #{token}" }
    end

    let(:params) do
      {
        invoice_number: 'INV-200',
        customer_url: 'https://example.com/return',
        reference_number: 'REF-1'
      }
    end

    it 'returns 201 and redirect link on success' do
      service = instance_double(Oneoff)
      allow(Oneoff).to receive(:call).and_return(Struct.new(:result?, :instance, :errors).new(true, { 'payment_link' => 'https://pay' }, nil))

      post '/api/v1/invoice_generator/oneoff', params: params, headers: auth_headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['oneoff_redirect_link']).to eq('https://pay')
    end

    it 'returns 422 on failure' do
      allow(Oneoff).to receive(:call).and_return(Struct.new(:result?, :instance, :errors).new(false, nil, { error: 'invalid' }))

      post '/api/v1/invoice_generator/oneoff', params: params, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end


