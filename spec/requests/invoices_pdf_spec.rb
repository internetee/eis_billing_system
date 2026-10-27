require 'rails_helper'

RSpec.describe 'Invoice PDF download', type: :request do
  let(:user) { create(:user) }
  let(:invoice) { create(:invoice) }

  describe 'GET /invoices/:id/pdf' do
    context 'when logged in' do
      before do
        allow(Current).to receive(:user).and_return(user)
      end

      it 'returns the invoice PDF as an attachment' do
        get pdf_invoice_path(invoice)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('application/pdf')
        expect(response.headers['Content-Disposition'])
          .to include("Invoice-#{invoice.invoice_number}.pdf")
        expect(response.body).to start_with('%PDF')
      end
    end

    context 'when not logged in' do
      it 'requires login' do
        get pdf_invoice_path(invoice)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
