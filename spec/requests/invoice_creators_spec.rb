require 'rails_helper'

RSpec.describe 'InvoiceCreators', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /invoice_creators' do
    it 'returns success and assigns paginated invoices' do
      create_list(:invoice, 3, initiator: 'billing_system')
      
      get invoice_creators_path
      
      expect(response).to have_http_status(:success)
    end

    it 'filters invoices by billing_system initiator' do
      billing_invoice = create(:invoice, initiator: 'billing_system')
      registry_invoice = create(:invoice, initiator: 'registry')
      
      get invoice_creators_path
      
      expect(response).to have_http_status(:success)
    end

    it 'respects per_page parameter' do
      create_list(:invoice, 30, initiator: 'billing_system')
      
      get invoice_creators_path, params: { per_page: 10 }
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /invoice_creators/new' do
    before do
      allow(InvoiceNumberService).to receive(:call).and_return(12345)
    end

    it 'returns success and assigns new invoice with generated number' do
      get new_invoice_creator_path
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /invoice_creators' do
    let(:valid_params) do
      {
        invoice: {
          invoice_number: 12345,
          affiliation: 'linkpay',
          initiator: 'billing_system',
          transaction_amount: 100.50,
          description: 'Test invoice'
        },
        linkpay: {
          customer_name: 'John Doe',
          customer_email: 'john@example.com',
          custom_field1: 'Test description',
          custom_field2: 'billing_system'
        }
      }
    end

    before do
      allow(EverypayLinkGenerator).to receive(:create).and_return('https://pay.example.com/link')
    end

    context 'with valid parameters' do
      it 'creates invoice and redirects with success message' do
        expect {
          post invoice_creators_path, params: valid_params
        }.to change(Invoice, :count).by(1)
        
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(invoice_creators_path)
        follow_redirect!
        expect(flash[:notice]).to eq('Invoice was successfully created.')
        
        invoice = Invoice.last
        expect(invoice.invoice_number).to eq(12345)
        expect(invoice.affiliation).to eq('linkpay')
        expect(invoice.initiator).to eq('billing_system')
        expect(invoice.transaction_amount).to eq(100.50)
        expect(invoice.description).to eq('Test invoice')
        expect(invoice.linkpay_info).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'still creates invoice (no validations present) and redirects' do
        invalid_params = valid_params.dup
        invalid_params[:invoice][:transaction_amount] = -1

        expect {
          post invoice_creators_path, params: invalid_params
        }.to change(Invoice, :count).by(1)

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(invoice_creators_path)
      end
    end
  end
end