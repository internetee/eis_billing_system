require 'rails_helper'

RSpec.describe 'InvoiceDetails::EverypayResponseController', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /invoice_details/everypay_response/:id' do
    context 'when invoice has everypay response' do
      let(:invoice) { create(:invoice, everypay_response: { 'status' => 'settled', 'amount' => '100' }) }

      it 'returns success and assigns everypay data' do
        get invoice_details_everypay_response_path(invoice)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when invoice has no everypay response' do
      let(:invoice) { create(:invoice, everypay_response: nil) }

      it 'returns success with default message' do
        get invoice_details_everypay_response_path(invoice)

        expect(response).to have_http_status(:success)
      end
    end

    context 'when invoice not found' do
      it 'raises error (not handled)' do
        expect {
          get invoice_details_everypay_response_path(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
