require 'rails_helper'

RSpec.describe 'Api::V1::CallbackHandler::MontonioController', type: :request do
  let(:access_key) { 'test-access-key' }
  let(:secret_key) { 'test-secret-key' }
  let(:auction_url) { GlobalVariable::AUCTION_PAYMENT_URL }

  let!(:admin) { create(:user) }
  let(:invoice) do
    create(:invoice, invoice_number: 4321, initiator: 'auction', transaction_amount: '10.5',
                     payment_reference: nil, payment_link_uuid: 'link-uuid-1',
                     payment_link_provider: 'montonio', payment_link: 'https://pay.montonio.com/link-uuid-1')
  end

  def order_token(overrides = {}, key = secret_key)
    payload = {
      uuid: 'order-uuid-1',
      accessKey: access_key,
      paymentStatus: 'PAID',
      paymentMethod: 'paymentInitiation',
      grandTotal: 10.5,
      currency: 'EUR',
      paymentLinkUuid: 'link-uuid-1',
      iat: Time.zone.now.to_i,
      exp: Time.zone.now.to_i + 600
    }.merge(overrides)

    JWT.encode(payload, key, 'HS256')
  end

  def post_webhook(body)
    post '/api/v1/callback_handler/montonio', params: body.to_json,
                                              headers: { 'Content-Type' => 'application/json' }
  end

  def json
    JSON.parse(response.body)
  end

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.deliveries.clear
    stub_const('GlobalVariable::MONTONIO_ACCESS_KEY', access_key)
    stub_const('GlobalVariable::MONTONIO_SECRET_KEY', secret_key)
    stub_request(:put, auction_url).to_return(status: 200, body: { message: 'received' }.to_json)
    invoice
  end

  context 'with a verified PAID token' do
    it 'marks the invoice as paid and notifies the auction' do
      post_webhook(orderToken: order_token)

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('processed')

      invoice.reload
      expect(invoice.status).to eq('paid')
      expect(invoice.payment_reference).to eq('order-uuid-1')
      expect(invoice.transaction_time).to be_present
      expect(invoice.linkpay_info['montonio_orders']).to have_key('order-uuid-1')

      expect(WebMock).to have_requested(:put, auction_url).with { |request|
        body = JSON.parse(request.body)
        body['order_reference'] == '4321' &&
          body['payment_state'] == 'settled' &&
          body['payment_reference'] == 'order-uuid-1' &&
          body['payment_provider'] == 'montonio' &&
          body['initial_amount'] == 10.5 &&
          body['standing_amount'] == 10.5 &&
          body['invoice_number_collection'].nil? &&
          body['transaction_time'].present?
      }
    end

    it 'is a no-op when the same webhook is delivered again' do
      token = order_token
      post_webhook(orderToken: token)
      post_webhook(orderToken: token)

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('already_processed')
      expect(WebMock).to have_requested(:put, auction_url).once
    end
  end

  context 'with a token we cannot trust' do
    it 'rejects a token signed with another key' do
      post_webhook(orderToken: order_token({}, 'someone-elses-key'))

      expect(response).to have_http_status(:unauthorized)
      expect(invoice.reload.status).to eq('unpaid')
    end

    it 'rejects a token issued for another store' do
      post_webhook(orderToken: order_token(accessKey: 'other-store'))

      expect(response).to have_http_status(:unauthorized)
      expect(invoice.reload.status).to eq('unpaid')
    end

    it 'rejects a missing token' do
      post_webhook({})

      expect(response).to have_http_status(:unauthorized)
    end

    it 'rejects an unknown payment link' do
      post_webhook(orderToken: order_token(paymentLinkUuid: 'nope'))

      expect(response).to have_http_status(:not_found)
      expect(invoice.reload.status).to eq('unpaid')
    end
  end

  context 'with a status that is not PAID' do
    it 'ignores PENDING and leaves the invoice alone' do
      post_webhook(orderToken: order_token(paymentStatus: 'PENDING'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('ignored')
      expect(invoice.reload.status).to eq('unpaid')
      expect(a_request(:put, auction_url)).not_to have_been_made
    end

    it 'asks for manual handling on VOIDED' do
      post_webhook(orderToken: order_token(paymentStatus: 'VOIDED'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('manual_review')
      expect(invoice.reload.status).to eq('unpaid')
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'asks for manual handling on REFUNDED even when the invoice is paid' do
      invoice.update!(status: :paid)

      post_webhook(orderToken: order_token(paymentStatus: 'REFUNDED'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('manual_review')
      expect(invoice.reload.status).to eq('paid')
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end
  end

  context 'when the payment does not match the invoice' do
    it 'does not mark the invoice paid when the amount differs' do
      post_webhook(orderToken: order_token(grandTotal: 1.0))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('amount_mismatch')

      invoice.reload
      expect(invoice.status).to eq('unpaid')
      expect(invoice.linkpay_info['montonio_discrepancies'].first)
        .to include('uuid' => 'order-uuid-1', 'grand_total' => 1.0)
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(a_request(:put, auction_url)).not_to have_been_made
    end

    it 'does not mark the invoice paid when the currency differs' do
      post_webhook(orderToken: order_token(currency: 'USD'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('amount_mismatch')
      expect(invoice.reload.status).to eq('unpaid')
    end
  end

  context 'when a second, different payment arrives for a paid invoice' do
    it 'reports a possible double payment without changing anything' do
      post_webhook(orderToken: order_token)
      expect(invoice.reload.status).to eq('paid')
      ActionMailer::Base.deliveries.clear

      post_webhook(orderToken: order_token(uuid: 'order-uuid-2'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('possible_double_payment')
      expect(invoice.reload.payment_reference).to eq('order-uuid-1')
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(WebMock).to have_requested(:put, auction_url).once
    end
  end

  context 'refund notifications' do
    it 'accepts a refundToken body without touching the invoice' do
      post_webhook(refundToken: order_token(paymentStatus: 'REFUNDED'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('refund_logged')
      expect(invoice.reload.status).to eq('unpaid')
    end

    it 'still answers 200 for an unverifiable refund token so montonio stops retrying' do
      post_webhook(refundToken: order_token({}, 'someone-elses-key'))

      expect(response).to have_http_status(:ok)
      expect(json['state']).to eq('refund_logged')
    end
  end
end
