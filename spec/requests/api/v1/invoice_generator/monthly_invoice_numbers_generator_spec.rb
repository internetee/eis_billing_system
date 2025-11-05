require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::MonthlyInvoiceNumbersGeneratorController', type: :request do
  let(:secret_key) { 'test_secret' }
  let(:token) { JWT.encode({ initiator: 'registry' }, secret_key, 'HS256') }
  let(:auth_headers) { { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' } }

  before do
    allow_any_instance_of(Api::V1::InvoiceGenerator::MonthlyInvoiceNumbersGeneratorController)
      .to receive(:billing_secret_key).and_return(secret_key)
    
    create(:setting_entry, code: 'directo_monthly_number_last', value: '309901', format: 'integer', group: 'directo')
    create(:setting_entry, code: 'directo_monthly_number_min', value: '309901', format: 'integer', group: 'directo')
    create(:setting_entry, code: 'directo_monthly_number_max', value: '309999', format: 'integer', group: 'directo')

    SettingEntry.find_by(code: 'directo_monthly_number_last')
    SettingEntry.find_by(code: 'directo_monthly_number_min')
    SettingEntry.find_by(code: 'directo_monthly_number_max')
  end

  describe 'POST /api/v1/invoice_generator/monthly_invoice_numbers_generator' do
    context 'with valid parameters' do
      it 'generates monthly invoice numbers and returns success' do
        post api_v1_invoice_generator_monthly_invoice_numbers_generator_index_path,
             params: { count: 5 }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['invoice_numbers']).to be_an(Array)
        expect(json['invoice_numbers'].size).to eq(5)
      end
    end

    context 'with out of range count' do
      before do
        SettingEntry.find_by(code: 'directo_monthly_number_last').update(value: '309995')
      end

      it 'returns error when count exceeds range' do
        post api_v1_invoice_generator_monthly_invoice_numbers_generator_index_path,
             params: { count: 10 }.to_json,
             headers: auth_headers

        expect(response).to have_http_status(:not_implemented)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('out of range')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post api_v1_invoice_generator_monthly_invoice_numbers_generator_index_path,
             params: { count: 5 }.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with missing count parameter' do
      it 'raises TypeError when count is missing (controller expects integer)' do
        expect {
          post api_v1_invoice_generator_monthly_invoice_numbers_generator_index_path,
               params: {}.to_json,
               headers: auth_headers
        }.to raise_error(TypeError)
      end
    end
  end
end
