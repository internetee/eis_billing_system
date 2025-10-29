require 'rails_helper'

RSpec.describe RefundService do
  let(:amount) { 10.5 }
  let(:payment_reference) { 'PAY-REF-XYZ' }
  let(:service) { described_class.new(amount: amount, payment_reference: payment_reference) }

  describe '#call' do
    it 'returns success struct when everypay responds ok' do
      ok_response = { 'ok' => true }
      # Mock contract to pass validation
      contract = instance_double(RefundContract)
      allow(RefundContract).to receive(:new).and_return(contract)
      success = double(success?: true)
      allow(contract).to receive(:call).and_return(success)
      allow(service).to receive(:post).and_return(ok_response)

      result = service.call

      expect(result.result?).to eq(true)
      expect(result.instance).to eq(ok_response.with_indifferent_access)
      expect(result.errors).to be_nil
    end

    it 'returns error struct when everypay responds with error' do
      error_response = { 'error' => 'invalid' }
      # Mock contract to pass validation
      contract = instance_double(RefundContract)
      allow(RefundContract).to receive(:new).and_return(contract)
      success = double(success?: true)
      allow(contract).to receive(:call).and_return(success)
      allow(service).to receive(:post).and_return(error_response)

      result = service.call

      expect(result.result?).to eq(false)
      expect(result.errors).to eq('invalid')
    end

    it 'validates params and returns errors on invalid' do
      invalid_service = described_class.new(amount: nil, payment_reference: nil)
      # Stub contract to return failure-like struct
      contract = instance_double(RefundContract)
      allow(RefundContract).to receive(:new).and_return(contract)
      failure = double(success?: false, errors: double(to_h: { amount: ['is missing'], payment_reference: ['is missing'] }))
      allow(contract).to receive(:call).and_return(failure)

      result = invalid_service.call
      expect(result.result?).to eq(false)
      expect(result.errors).to eq({ amount: ['is missing'], payment_reference: ['is missing'] })
    end
  end
end


