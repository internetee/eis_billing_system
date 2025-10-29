require 'rails_helper'

RSpec.describe 'InvoiceDetails::PaymentReferencesController', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /invoice_details/payment_references/:id' do
    subject(:request_call) { get invoice_details_payment_reference_path(invoice) }

    context 'when invoice has payment reference' do
      let(:invoice) { create(:invoice, payment_reference: 'REF12345') }

      it 'returns success and assigns payment reference' do
        request_call
        expect(response).to have_http_status(:success)
        expect(response.body).to include('REF12345')
      end
    end

    context 'when invoice has no payment reference' do
      let(:invoice) { create(:invoice, payment_reference: nil) }

      it 'returns success' do
        request_call
        expect(response).to have_http_status(:success)
      end
    end

    context 'when invoice not found' do
      let(:invoice) { double(id: 99999) }
      
      it 'raises error (not handled)' do
        expect {
          get invoice_details_payment_reference_path(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
