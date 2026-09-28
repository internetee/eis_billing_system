require 'rails_helper'

RSpec.describe Montonio::PaymentLinkGenerator do
  let(:access_key) { 'test-access-key' }
  let(:secret_key) { 'test-secret-key' }
  let(:base_url) { 'https://sandbox-stargate.montonio.com/api' }
  let(:endpoint) { "#{base_url}/payment-links" }
  let(:notification_url) { 'https://billing.test/api/v1/callback_handler/montonio' }

  let(:montonio_response) do
    { uuid: 'link-uuid-1', url: 'https://pay.montonio.com/link-uuid-1', shortUrl: 'https://mon.io/abc' }
  end

  before do
    stub_const('GlobalVariable::MONTONIO_BASE', base_url)
    stub_const('GlobalVariable::MONTONIO_ACCESS_KEY', access_key)
    stub_const('GlobalVariable::MONTONIO_SECRET_KEY', secret_key)
    stub_const('GlobalVariable::MONTONIO_NOTIFICATION_URL', notification_url)
  end

  def generate(overrides = {})
    described_class.call(**{ invoice_number: 1234,
                             amount: '10.5',
                             description: 'Auction invoice',
                             expires_at: '2026-07-09T20:59:59Z',
                             locale: 'et',
                             return_url: 'https://auction.test/invoices/1' }.merge(overrides))
  end

  def sent_token
    JWT.decode(JSON.parse(@sent_body)['data'], secret_key, true, algorithm: 'HS256').first
  end

  describe '.call' do
    before do
      stub_request(:post, endpoint).to_return do |request|
        @sent_body = request.body
        { status: 201, body: montonio_response.to_json }
      end
    end

    it 'posts the signed token to the payment links endpoint' do
      generate

      expect(WebMock).to have_requested(:post, endpoint)
        .with(headers: { 'Content-Type' => 'application/json' }) { |req| JSON.parse(req.body).key?('data') }
    end

    it 'signs a token that carries everything Montonio needs' do
      generate

      expect(sent_token).to include('accessKey' => access_key,
                                    'description' => '1234 Auction invoice',
                                    'currency' => 'EUR',
                                    'amount' => 10.5,
                                    'locale' => 'et',
                                    'askAdditionalInfo' => false,
                                    'expiresAt' => '2026-07-09T20:59:59Z',
                                    'notificationUrl' => notification_url,
                                    'returnUrl' => 'https://auction.test/invoices/1')
    end

    it 'does not send merchantReference or paymentReference' do
      generate

      expect(sent_token).not_to have_key('merchantReference')
      expect(sent_token).not_to have_key('paymentReference')
    end

    it 'gives the token a short lifetime of its own' do
      generate

      expect(sent_token['exp']).to be_within(60).of(Time.zone.now.to_i + described_class::TOKEN_TTL_IN_SECONDS)
    end

    it 'falls back to english for unsupported locales' do
      generate(locale: 'es')

      expect(sent_token['locale']).to eq('en')
    end

    it 'omits the return url when it is blank' do
      generate(return_url: '')

      expect(sent_token).not_to have_key('returnUrl')
    end

    it 'rounds the amount to two decimals' do
      generate(amount: '10.555')

      expect(sent_token['amount']).to eq(10.56)
    end

    it 'returns the created link' do
      link = generate

      expect(link.uuid).to eq('link-uuid-1')
      expect(link.url).to eq('https://pay.montonio.com/link-uuid-1')
      expect(link.short_url).to eq('https://mon.io/abc')
      expect(link.expires_at).to eq('2026-07-09T20:59:59Z')
    end
  end

  describe 'error handling' do
    it 'raises when Montonio refuses the request' do
      stub_request(:post, endpoint).to_return(status: 401, body: { error: 'STORE_NOT_FOUND' }.to_json)

      expect { generate }.to raise_error(Montonio::RequestError, /401/)
    end

    it 'raises when the response carries no url' do
      stub_request(:post, endpoint).to_return(status: 201, body: { uuid: 'x' }.to_json)

      expect { generate }.to raise_error(Montonio::RequestError, /no payment link url/)
    end

    it 'raises when the response is not json' do
      stub_request(:post, endpoint).to_return(status: 200, body: '<html>oops</html>')

      expect { generate }.to raise_error(Montonio::RequestError, /not valid JSON/)
    end

    it 'raises when Montonio times out' do
      stub_request(:post, endpoint).to_timeout

      expect { generate }.to raise_error(Faraday::Error)
    end

    it 'raises when the keys are missing' do
      stub_const('GlobalVariable::MONTONIO_SECRET_KEY', nil)

      expect { generate }.to raise_error(Montonio::ConfigurationError)
    end

    it 'raises when there is no expiry' do
      expect { generate(expires_at: nil) }.to raise_error(Montonio::RequestError, /requires an expiry/)
    end
  end
end
