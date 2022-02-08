require 'rails_helper'

RSpec.describe 'Api::V1::ImportData::InvoiceData', type: :request do
  describe 'POST /create' do
    it 'should import invoice data from registry' do
      invoice_data = { '_json' => [{
        'invoice_number' => '001',
        'initiator' => 'registry',
        'transaction_amount' => '12.0'
      }, {
        'invoice_number' => '002',
        'initiator' => 'registry',
        'transaction_amount' => '12.0'
      }] }

      expect { post api_v1_import_data_invoice_data_url, params: invoice_data}.to change { Invoice.count }.by(2)

      expect(response).to have_http_status(:success)
    end

    it 'should skip if data duplicate' do
      invoice_data = { '_json' => [{
        'invoice_number' => '333',
        'initiator' => 'registry',
        'transaction_amount' => '12.0'
      }, {
        'invoice_number' => '333',
        'initiator' => 'registry',
        'transaction_amount' => '12.0'
      }] }

      expect { post api_v1_import_data_invoice_data_url, params: invoice_data}.to change { Invoice.count }.by(1)

      expect(Invoice.last.initiator).to eq('registry')
      expect(Invoice.last.invoice_number).to eq(333)
      expect(response).to have_http_status(:success)
    end

    it 'should import invoice data from auction' do
      invoice_data = { '_json' => [{
        'invoice_number' => '123',
        'initiator' => 'auction',
        'transaction_amount' => '12.0'
      }, {
        'invoice_number' => '321',
        'initiator' => 'auction',
        'transaction_amount' => '12.0'
      }] }

      expect { post api_v1_import_data_invoice_data_url, params: invoice_data}.to change { Invoice.count }.by(2)

      expect(Invoice.last.initiator).to eq('auction')
      expect(response).to have_http_status(:success)
    end
  end
end