require 'rails_helper'

RSpec.describe 'Api::V1::Invoice::UpdateInvoiceDataController', type: :request do
  let(:auth_headers) { { 'Authorization' => "Bearer #{JWT.encode({ initiator: 'registry' }, ENV['billing_secret'] || 'test_secret')}" } }

  before do
    stub_const('ENV', ENV.to_h.merge('billing_secret' => 'test_secret'))
  end

  describe 'PATCH /api/v1/invoice/update_invoice_data' do
    let(:invoice) { create(:invoice, invoice_number: 12345, transaction_amount: 100.0) }
    let(:params) { { invoice_number: invoice.invoice_number, transaction_amount: 200.0 } }
    subject(:request_call) { patch api_v1_invoice_update_invoice_data_path, params: params, headers: auth_headers }

    context 'with valid parameters' do
      it 'updates invoice and returns success message' do
        request_call

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Invoice data was successfully updated')
        expect(invoice.reload.transaction_amount).to eq(200.0)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { invoice_number: invoice.invoice_number, transaction_amount: 'invalid' } }
      
      it 'converts invalid string to 0.0 and succeeds' do
        request_call

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Invoice data was successfully updated')
        expect(invoice.reload.transaction_amount).to eq(0.0)
      end
    end

    context 'when invoice not found' do
      let(:params) { { invoice_number: 99999, transaction_amount: 200.0 } }
      
      it 'raises error (not handled)' do
        expect {
          request_call
        }.to raise_error(NoMethodError)
      end
    end

    context 'without authentication' do
      subject(:request_call) { patch api_v1_invoice_update_invoice_data_path, params: params }
      
      it 'returns unauthorized' do
        request_call

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
