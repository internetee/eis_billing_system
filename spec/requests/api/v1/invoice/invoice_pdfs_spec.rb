require 'rails_helper'

RSpec.describe 'Api::V1::Invoice::InvoicePdfsController', type: :request do
  let(:secret_key) { 'test_secret' }
  let(:token) { JWT.encode({ initiator: 'registry' }, secret_key, 'HS256') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' } }

  let(:invoice_payload) do
    {
      'number' => '222331',
      'issue_date' => '2026-10-01',
      'due_date' => '2026-10-15',
      'cancelled_at' => nil,
      'description' => 'Domain registration',
      'reference_no' => '120837465',
      'currency' => 'EUR',
      'vat_rate' => '22.0',
      'total' => '12.20',
      'monthly_invoice' => false,
      'buyer_name' => 'Registrar OÜ',
      'buyer_reg_no' => '12345678',
      'buyer_vat_no' => 'EE123456789',
      'buyer_street' => 'Pärnu mnt 139e',
      'buyer_city' => 'Tallinn',
      'buyer_state' => 'Harju maakond',
      'buyer_zip' => '11317',
      'buyer_country_code' => 'EE',
      'buyer_phone' => '+372.5551234',
      'buyer_url' => 'https://registrar.ee',
      'buyer_email' => 'billing@registrar.ee',
      'seller_name' => 'Eesti Interneti Sihtasutus',
      'seller_reg_no' => '90010019',
      'seller_vat_no' => 'EE101086470',
      'seller_street' => 'Paldiski mnt 80',
      'seller_city' => 'Tallinn',
      'seller_state' => 'Harju maakond',
      'seller_zip' => '10617',
      'seller_country_code' => 'EE',
      'seller_phone' => '+372.727.1000',
      'seller_email' => 'arveldused@internet.ee',
      'seller_url' => 'www.internet.ee',
      'seller_bank' => 'LHV Pank',
      'seller_iban' => 'EE557700771000598813',
      'seller_swift' => 'LHVBEE22'
    }
  end

  let(:items_payload) do
    [
      {
        'description' => 'Domain test.ee registration for 1 year',
        'unit' => 'piece',
        'quantity' => 1,
        'price' => '10.00',
        'subtotal' => '10.00',
        'vat_rate' => '22.0',
        'vat_amount' => '2.20',
        'total' => '12.20'
      }
    ]
  end

  let(:valid_payload) do
    {
      invoice: invoice_payload,
      items: items_payload,
      invoice_subtotal: '10.00',
      vat_amount: '2.20'
    }
  end

  before do
    allow_any_instance_of(Api::V1::Invoice::InvoicePdfsController)
      .to receive(:billing_secret_key).and_return(secret_key)
  end

  describe 'POST /api/v1/invoice/invoice_pdf' do
    context 'without authentication' do
      it 'returns unauthorized' do
        post api_v1_invoice_invoice_pdf_path,
             params: valid_payload.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized' do
        post api_v1_invoice_invoice_pdf_path,
             params: valid_payload.to_json,
             headers: { 'Authorization' => 'Bearer invalid_token', 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with missing invoice data' do
      it 'returns unprocessable entity' do
        post api_v1_invoice_invoice_pdf_path,
             params: { items: items_payload }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to be_present
      end
    end

    context 'with missing invoice number' do
      it 'returns unprocessable entity' do
        post api_v1_invoice_invoice_pdf_path,
             params: { invoice: invoice_payload.except('number'), items: items_payload }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to be_present
      end
    end

    context 'with missing items' do
      it 'returns unprocessable entity' do
        post api_v1_invoice_invoice_pdf_path,
             params: { invoice: invoice_payload }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to be_present
      end
    end

    context 'with valid payload' do
      it 'returns generated PDF file' do
        post api_v1_invoice_invoice_pdf_path,
             params: valid_payload.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('application/pdf')
        expect(response.headers['Content-Disposition'])
          .to include("Invoice-#{invoice_payload['number']}.pdf")
        expect(response.body).to start_with('%PDF')
      end
    end
  end
end
