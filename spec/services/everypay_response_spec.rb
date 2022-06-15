require 'rails_helper'

RSpec.describe 'EverypayResponse' do
  describe 'sending request to get information about invoice' do
    it 'should generate url with correct data' do
      api_username = 'api_username'
      payment_reference = 'payment_reference'

      everypay_fetcher = EverypayResponse.new(payment_reference)
      generated_link = everypay_fetcher.generate_url(payment_reference: payment_reference, api_username: api_username)

      expect(generated_link).to eq('https://igw-demo.every-pay.com/api/v4/payments/payment_reference?api_username=api_username')
    end
  end
end
