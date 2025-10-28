require 'rails_helper'

RSpec.describe EverypayLinkGenerator do
  let(:params) do
    {
      transaction_amount: 100.50,
      reference_number: '1234567890',
      invoice_number: 'INV-001',
      customer_name: 'John Doe',
      customer_email: 'john@example.com',
      custom_field1: 'test_field',
      custom_field2: 'registry'
    }
  end

  describe '.create' do
    it 'generates a valid payment link with all required parameters' do
      link = described_class.create(params: params)
      
      expect(link).to start_with(GlobalVariable::LINKPAY_PREFIX)
      expect(link).to include('transaction_amount=100.5')
      expect(link).to include('invoice_number=INV-001')
      expect(link).to include('customer_name=John%20Doe')
      expect(link).to include('hmac=') 
    end

    it 'handles missing custom_field1 gracefully' do
      params_without_custom1 = params.except(:custom_field1)
      link = described_class.create(params: params_without_custom1)
      
      expect(link).to start_with(GlobalVariable::LINKPAY_PREFIX)
      expect(link).to include('custom_field_1=')
    end

    it 'replaces plus signs with %20 in URL encoding' do
      params_with_spaces = params.merge(customer_name: 'John Smith')
      link = described_class.create(params: params_with_spaces)
      
      expect(link).to include('John%20Smith')
      expect(link).not_to include('John Smith')
    end
  end

  describe '#linkpay_params' do
    let(:generator) { described_class.new(params: params) }

    it 'formats all parameters correctly' do
      result = generator.linkpay_params(params)
      
      expect(result['transaction_amount']).to eq('100.5')
      expect(result['reference_number']).to eq('1234567890')
      expect(result['order_reference']).to eq('INV-001')
      expect(result['customer_name']).to eq('John Doe')
      expect(result['customer_email']).to eq('john@example.com')
      expect(result['custom_field_1']).to eq('test_field')
      expect(result['custom_field_2']).to eq('registry')
      expect(result['linkpay_token']).to eq(GlobalVariable::LINKPAY_TOKEN)
      expect(result['invoice_number']).to eq('INV-001')
    end

    it 'handles empty custom_field1' do
      params_without_custom1 = params.except(:custom_field1)
      result = generator.linkpay_params(params_without_custom1)
      
      expect(result['custom_field_1']).to eq('')
    end
  end

  describe '#build_link' do
    let(:generator) { described_class.new(params: params) }
    let(:query_string) { 'transaction_amount=100.5&reference_number=1234567890' }

    it 'generates HMAC signature correctly' do
      link = generator.build_link(query_string)
      
      expect(link).to start_with("#{GlobalVariable::LINKPAY_PREFIX}?#{query_string}&hmac=")
      
      hmac = link.split('hmac=').last
      expect(hmac).to match(/\A[a-f0-9]{64}\z/)
    end

    it 'verifies HMAC integrity' do
      link = generator.build_link(query_string)
      hmac = link.split('hmac=').last
      
      expected_hmac = OpenSSL::HMAC.hexdigest('sha256', GlobalVariable::KEY, query_string)
      expect(hmac).to eq(expected_hmac)
    end
  end
end
