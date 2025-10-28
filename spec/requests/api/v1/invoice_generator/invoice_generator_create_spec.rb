require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::InvoiceGeneratorController', type: :request do
  describe 'POST /api/v1/invoice_generator/invoice_generator' do
    before do
      allow_any_instance_of(ApplicationController).to receive(:billing_secret_key).and_return('test_secret')
    end
    let(:params) do
      {
        transaction_amount: '10.5',
        reference_number: '123',
        order_reference: 'INV-100',
        customer_name: 'John Doe',
        customer_email: 'john@example.com',
        custom_field_1: 'Topup',
        custom_field2: 'registry',
        linkpay_token: GlobalVariable::LINKPAY_TOKEN,
        invoice_number: 'INV-100'
      }
    end

    let(:auth_headers) do
      token = JWT.encode({ initiator: 'registry' }, 'test_secret')
      { 'Authorization' => "Bearer #{token}" }
    end

    it 'creates payment link and returns 201 with link' do
      allow(EverypayLinkGenerator).to receive(:create).and_return('https://pay.example/h?')
      
      expect { post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers }
        .to change { Invoice.count }.by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Link created')
      expect(json['everypay_link']).to be_present
    end

    it 'handles errors gracefully (logs and returns 204 with empty body)' do
      allow(InvoiceInstanceGenerator).to receive(:create).and_raise(StandardError.new('boom'))
      
      expect { post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers }.not_to raise_error
      expect(response).to have_http_status(:no_content)
    end
  end
end


