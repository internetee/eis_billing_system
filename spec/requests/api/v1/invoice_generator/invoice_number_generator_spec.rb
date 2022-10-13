require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::InvoiceNumberGenerators', type: :request do
  let(:invoice) { build(:invoice) }
  describe 'POST /create' do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it 'should generate number for invoice' do
      expect(InvoiceNumberService).to receive(:call).and_return('2323')
      post api_v1_invoice_generator_invoice_number_generator_index_url

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['invoice_number']).to eq('2323')
    end

    it 'should generate number for invoice which will be one more than the previous number' do
      invoice.invoice_number = InvoiceNumberService::INVOICE_NUMBER_MIN
      invoice.save

      post api_v1_invoice_generator_invoice_number_generator_index_url

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['invoice_number']).to eq(invoice.invoice_number + 1)
    end

    it 'if no any invoice should be return minimum range of invoice number' do
      post api_v1_invoice_generator_invoice_number_generator_index_url

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['invoice_number']).to eq(InvoiceNumberService::INVOICE_NUMBER_MIN)
    end
  end
end
