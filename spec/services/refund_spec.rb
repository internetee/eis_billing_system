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

  # event_name=refund_failed
  # должно прийти в коллбэк???
  refund_failed = {
    'api_username' => 'abc12345',
    'initial_amount' => '2.50',
    'standing_amount' => '1.50',
    'transaction_time' => '2015-04-02T07:53:07Z',
    'payment_reference' => 'db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a',
    'payment_state' => 'refund_failed'
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
        payment_reference: invoice.payment_reference,
        timestamp: '2015-04-02T07:53:07Z'
      )

      expect(response.result?).to eq true
      expect(response.instance).to a_hash_including(refund_response)
    end
  end

  describe 'third party problems' do
  end

  describe 'validations' do
    it 'should return false results if payment reference is invalid' do
      response = described_class.call(
        amount: invoice.transaction_amount,
        payment_reference: 'invalid',
        timestamp: '2015-04-02T07:53:07Z'
      )

      expect(response.result?).to eq false
    end
  end
end
