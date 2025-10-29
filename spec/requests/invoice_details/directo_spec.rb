require 'rails_helper'

RSpec.describe 'InvoiceDetails::DirectoController', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /invoice_details/directo/:id' do
    subject(:request_call) { get invoice_details_directo_path(invoice) }

    context 'when invoice has directo_data XML' do
      let(:xml) { '<root><value>1</value></root>' }
      let(:invoice) { create(:invoice, directo_data: xml) }

      it 'returns success and renders formatted XML' do
        request_call
        expect(response).to have_http_status(:success)
        expect(response.body).to include('root')
        expect(response.body).to include('value')
      end
    end

    context 'when invoice has no directo_data' do
      let(:invoice) { create(:invoice, directo_data: nil) }

      it 'returns success with default message' do
        request_call
        expect(response).to have_http_status(:success)
        expect(response.body).to include('No data from directo')
      end
    end

    context 'when invoice not found' do
      it 'raises error (not handled)' do
        expect {
          get invoice_details_directo_path(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
