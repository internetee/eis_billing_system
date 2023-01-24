RSpec.describe RefundService do
  let(:invoice) { create(:invoice) }

  refund_response = {
    'api_username' => 'abc12345',
    'initial_amount' => '2.50',
    'standing_amount' => '1.50',
    'transaction_time' => '2015-04-02T07:53:07Z',
    'payment_reference' => 'db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a',
    'payment_state' => 'refunded'
  }

  refund_failed = {
    "error": {
        "code": 4997,
        "message": "The timestamp is not valid"
    }
  }

  open_bank_not_support_refund =
    {
        "error": {
            "code": 4037,
            "message": "Open banking payments cannot be refunded"
        }
    }

  describe 'success case' do
    before(:each) do
      stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
        .to_return(status: 200, body: refund_response.to_json, headers: {})

      invoice.reload
    end

    it 'successfully refund' do
      response = described_class.call(
        amount: invoice.transaction_amount,
        payment_reference: invoice.payment_reference
      )

      expect(response.result?).to eq true
      expect(response.instance).to a_hash_including(refund_response)
    end
  end

  describe 'third party problems' do
    it 'comes invalid timestamp response' do
      stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
      .to_return(status: 200, body: refund_failed.to_json, headers: {})

      invoice.reload

      response = described_class.call(
        amount: invoice.transaction_amount,
        payment_reference: invoice.payment_reference
      )

      expect(response.result?).to eq false
    end

    it 'open bank not supported refund' do
      stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
      .to_return(status: 200, body: open_bank_not_support_refund.to_json, headers: {})

      invoice.reload

      response = described_class.call(
        amount: invoice.transaction_amount,
        payment_reference: invoice.payment_reference
      )

      expect(response.result?).to eq false
    end
  end

  describe 'validations' do
    it 'should return false results if payment reference is invalid' do
      response = described_class.call(
        amount: invoice.transaction_amount,
        payment_reference: 'invalid'
      )

      expect(response.result?).to eq false
    end
  end
end
