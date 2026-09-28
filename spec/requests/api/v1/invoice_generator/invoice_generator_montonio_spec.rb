require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::InvoiceGeneratorController montonio links', type: :request do
  let(:access_key) { 'test-access-key' }
  let(:secret_key) { 'test-secret-key' }
  let(:base_url) { 'https://sandbox-stargate.montonio.com/api' }
  let(:endpoint) { "#{base_url}/payment-links" }
  let(:montonio_url) { 'https://pay.montonio.com/link-uuid-1' }

  let(:montonio_response) do
    { uuid: 'link-uuid-1', url: montonio_url, shortUrl: 'https://mon.io/abc' }
  end

  let(:params) do
    {
      transaction_amount: '10.5',
      reference_number: '123',
      order_reference: '1234',
      customer_name: 'John Doe',
      customer_email: 'john@example.com',
      custom_field1: 'Auction invoice',
      custom_field2: 'auction',
      linkpay_token: GlobalVariable::LINKPAY_TOKEN,
      invoice_number: '1234',
      due_date: '2026-07-09',
      return_url: 'https://auction.test/invoices/1',
      locale: 'et'
    }
  end

  def auth_headers(initiator)
    { 'Authorization' => "Bearer #{JWT.encode({ initiator: initiator }, 'test_secret')}" }
  end

  def json
    JSON.parse(response.body)
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:billing_secret_key).and_return('test_secret')
    stub_const('GlobalVariable::MONTONIO_BASE', base_url)
    stub_const('GlobalVariable::MONTONIO_ACCESS_KEY', access_key)
    stub_const('GlobalVariable::MONTONIO_SECRET_KEY', secret_key)
    stub_const('GlobalVariable::MONTONIO_NOTIFICATION_URL', 'https://billing.test/api/v1/callback_handler/montonio')
  end

  context 'auction invoice with a due date' do
    before { stub_request(:post, endpoint).to_return(status: 201, body: montonio_response.to_json) }

    it 'returns the montonio link and its expiry alongside the everypay link' do
      post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers('auction')

      expect(response).to have_http_status(:created)
      expect(json['message']).to eq('Link created')
      expect(json['everypay_link']).to start_with(GlobalVariable::LINKPAY_PREFIX)
      expect(json['payment_link']).to eq(montonio_url)
      expect(json['payment_link_provider']).to eq('montonio')
      expect(json['payment_link_expires_at']).to eq('2026-07-09T20:59:59Z')
    end

    it 'persists the montonio link on the invoice' do
      post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers('auction')

      invoice = Invoice.find_by(invoice_number: 1234)
      expect(invoice.payment_link).to eq(montonio_url)
      expect(invoice.payment_link_uuid).to eq('link-uuid-1')
      expect(invoice.payment_link_provider).to eq('montonio')
      expect(invoice.due_date).to eq(Date.new(2026, 7, 9))
      expect(invoice.linkpay_info['montonio']).to include('uuid' => 'link-uuid-1',
                                                          'url' => montonio_url,
                                                          'expires_at' => '2026-07-09T20:59:59Z')
    end
  end

  context 'when montonio fails' do
    it 'falls back to the everypay link' do
      stub_request(:post, endpoint).to_return(status: 500, body: '{"error":"boom"}')

      post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers('auction')

      expect(response).to have_http_status(:created)
      expect(json['payment_link']).to eq(json['everypay_link'])
      expect(json['payment_link_provider']).to eq('everypay')
      expect(json['payment_link_expires_at']).to be_nil

      invoice = Invoice.find_by(invoice_number: 1234)
      expect(invoice.payment_link_provider).to eq('everypay')
      expect(invoice.payment_link_uuid).to be_nil
      expect(invoice.due_date).to eq(Date.new(2026, 7, 9))
    end

    it 'falls back to the everypay link when montonio is not configured' do
      stub_const('GlobalVariable::MONTONIO_ACCESS_KEY', '')

      post '/api/v1/invoice_generator/invoice_generator', params: params, headers: auth_headers('auction')

      expect(response).to have_http_status(:created)
      expect(json['payment_link']).to eq(json['everypay_link'])
      expect(json['payment_link_provider']).to eq('everypay')
      expect(a_request(:post, endpoint)).not_to have_been_made
    end
  end

  context 'other initiators' do
    it 'keeps using everypay only' do
      registry_params = params.merge(custom_field2: 'registry', due_date: '2026-07-09')

      post '/api/v1/invoice_generator/invoice_generator', params: registry_params, headers: auth_headers('registry')

      expect(response).to have_http_status(:created)
      expect(json['payment_link']).to eq(json['everypay_link'])
      expect(json['payment_link_provider']).to eq('everypay')
      expect(json['payment_link_expires_at']).to be_nil
      expect(a_request(:post, endpoint)).not_to have_been_made
      expect(Invoice.find_by(invoice_number: 1234).payment_link).to be_nil
    end
  end

  context 'auction invoice without a due date' do
    it 'keeps using everypay' do
      post '/api/v1/invoice_generator/invoice_generator',
           params: params.except(:due_date), headers: auth_headers('auction')

      expect(response).to have_http_status(:created)
      expect(json['payment_link_provider']).to eq('everypay')
      expect(a_request(:post, endpoint)).not_to have_been_made
    end
  end

  context 'invalid due date' do
    it 'answers 422 and creates no invoice' do
      expect do
        post '/api/v1/invoice_generator/invoice_generator',
             params: params.merge(due_date: '09.07.2026'), headers: auth_headers('auction')
      end.not_to change(Invoice, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['message']).to match(/due_date/)
    end
  end
end
