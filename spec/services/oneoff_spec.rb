RSpec.describe Oneoff do
  describe 'successful case' do
    let(:invoice) { create(:invoice) }
    let(:customer_url_registry) { GlobalVariable::BASE_REGISTRY }
    let(:customer_url_eeid) { GlobalVariable::BASE_EEID }
    let(:customer_url_auction) { GlobalVariable::BASE_AUCTION }
    let(:reference) { create(:reference) }

    payment_link = { 'payment_link' => 'https://everypay.ee' }

    before(:each) do
      stub_request(:post, "#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::ONEOFF_ENDPOINT}")
        .to_return(status: 200, body: payment_link.to_json, headers: {})
    end

    it 'should generate oneoff link with reference number' do
      response = described_class.call(invoice_number: invoice.invoice_number.to_s,
                                      customer_url: customer_url_registry,
                                      reference_number: reference.to_s)
      expect(response).to a_hash_including(payment_link)
    end

    it 'should generate oneoff link without reference number' do
      response = described_class.call(invoice_number: invoice.invoice_number.to_s,
                                      customer_url: customer_url_registry,
                                      reference_number: nil)
      expect(response).to a_hash_including(payment_link)
    end

    it 'should generate oneoff link for eeid' do
      response = described_class.call(invoice_number: invoice.invoice_number.to_s,
                                      customer_url: customer_url_eeid,
                                      reference_number: nil)
      expect(response).to a_hash_including(payment_link)
    end

    it 'should generate oneoff link for auction' do
      response = described_class.call(invoice_number: invoice.invoice_number.to_s,
                                      customer_url: customer_url_auction,
                                      reference_number: nil)
      expect(response).to a_hash_including(payment_link)
    end
  end

  describe 'invalid case' do
    let(:invoice) { create(:invoice) }

    it 'should return error invalid url' do
      response = described_class.call(invoice_number: invoice.invoice_number.to_s,
                                      customer_url: 'http://thisisinvalidurl.com',
                                      reference_number: nil)

      expect(response['error']).to a_hash_including(
        'message' => 'this url not supported'
      )
    end

    it 'should return error missing invoice number' do
      response = described_class.call(invoice_number: nil,
                                      customer_url: GlobalVariable::BASE_REGISTRY,
                                      reference_number: nil)

      expect(response['error']).to a_hash_including(
        'message' => 'must be filled'
      )
    end
  end
end
