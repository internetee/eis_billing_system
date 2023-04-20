require 'rails_helper'

RSpec.describe "InvoiceStatus", type: :request do
  let(:user) { create(:user) }
  before(:each) do
    Current.user = user
    allow_any_instance_of(ParentController).to receive(:require_user_logged_in!).and_return(Current.user)

    mock_response = {
      'message' => 'Invoice data was successfully updated'
    }
    allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)
  end

  let(:invoice) { create(:invoice) }

  describe "POST update invoice status" do
    it 'should update the invoice status to paid' do
      expect(invoice.status).to eq 'unpaid'

      patch dashboards_invoice_status_path(invoice.id), params: { status: 'paid' }

      expect(invoice.reload.status).to eq 'paid'
    end

    it 'should update the invoice status to canceled' do
      expect(invoice.status).to eq 'unpaid'

      patch dashboards_invoice_status_path(invoice.id), params: { status: 'cancelled' }

      expect(invoice.reload.status).to eq 'cancelled'
    end

    it 'should update the invoice status to unpaid' do
      invoice.update(status: 'paid')
      expect(invoice.reload.status).to eq 'paid'

      patch dashboards_invoice_status_path(invoice.id), params: { status: 'unpaid' }

      expect(invoice.reload.status).to eq 'unpaid'
    end
  end
end
