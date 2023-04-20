require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::InvoiceStatusController', type: :request do
  describe 'Status handler' do
    let(:invoice) { create(:invoice) }

    before(:each) do
      allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true)
    end

    it 'should update status to cancelled' do
      params = {
        invoice_number: invoice.invoice_number,
        status: 'cancelled'
      }

      expect(invoice.status).to eq('unpaid')

      post api_v1_invoice_generator_invoice_status_index_path, params: params
      invoice.reload

      expect(invoice.status).to eq('cancelled')
    end

    it 'should update status to paid' do
      params = {
        invoice_number: invoice.invoice_number,
        status: 'paid'
      }
      invoice.update(status: 'unpaid')
      invoice.reload
      expect(invoice.status).to eq('unpaid')

      post api_v1_invoice_generator_invoice_status_index_path, params: params
      invoice.reload

      expect(invoice.status).to eq('paid')
    end
  end

  describe 'error handler' do
    let(:invoice) { create(:invoice) }
    let!(:admin) { create(:user) }

    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }
    before(:each) { ActionMailer::Base.delivery_method = :test }

    it 'should notify if status is invalid' do
      params = {
        invoice_number: invoice.invoice_number,
        status: 'another'
      }

      expect { post api_v1_invoice_generator_invoice_status_index_path, params: params }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'should notify if invoice not exists' do
      params = {
        invoice_number: '232323',
        status: 'another'
      }

      expect { post api_v1_invoice_generator_invoice_status_index_path, params: params }
        .to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end
