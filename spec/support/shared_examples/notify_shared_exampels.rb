RSpec.shared_examples 'should notify initiator' do |response_everypay|
  let(:invoice) { create(:invoice) }
  let(:invoice_s) { create(:invoice, invoice_number: 4) }

  before(:each) do
    stub_const('ENV', { 'update_payment_url' => 'http://endpoint:3000/get' })
    stub_const('ENV', { 'registry_update_payment_url' => 'http://endpoint/get' })
    # stub_const('ENV', { 'eeid_update_payment_url' => 'http://endpoint/get' })
  end

  it 'should notify registrar that response was receive in callback handler' do
    response = OpenStruct.new(code: 200)

    invoice.save
    expect(invoice.initiator).to eq('registry')

    uri_object = OpenStruct.new
    uri_object.host = 'http://endpoint/get'
    uri_object.port = '3000'

    allow(URI).to receive(:parse).and_return(uri_object)
    allow_any_instance_of(Net::HTTP).to receive(:put).and_return(response)

    res = Notify.call(JSON.parse(response_everypay.to_json))

    expect(res.code).to match(200)
  end

  describe 'notifier' do
    let!(:admin) { create(:user) }

    it 'should notify admin that error was occur' do
      title = 'error'
      text = 'very danger error happen'
      mailer = Notify.notify(title: title, error_message: text)

      expect(mailer.subject).to eq(title)
      expect(mailer.body). to include(text)
    end
  end

  describe 'update invoice status' do
    parsed_response = {}
    parsed_response[:payment_reference] = 'payment_reference'
    parsed_response[:transaction_time] = Time.zone.now - 1.minute
    parsed_response[:everypay_response] = { :everypay => 'ready' }

    let(:invoice) { create(:invoice) }

    it 'invoice should be mark as paid if invoice is settled' do
      parsed_response[:payment_state] = 'settled'

      expect(invoice.status).to eq('unpaid')

      Notify.update_invoice_state(parsed_response: parsed_response, invoice: invoice)
      invoice.reload

      expect(invoice.status).to eq('paid')
    end

    it 'invoice should be mark as failed if invoice is not settled' do
      parsed_response[:payment_state] = 'failed'

      expect(invoice.status).to eq('unpaid')

      Notify.update_invoice_state(parsed_response: parsed_response, invoice: invoice)
      invoice.reload

      expect(invoice.status).to eq('failed')
    end
  end

  describe 'multiple invoices' do
    let(:invoice_from_registry) { create(:invoice, initiator: 'registry') }
    let(:multiple_invoice) { create(:invoice, description: '10 20 30', initiator: 'auction') }
    let(:invoice_one) { build(:invoice, invoice_number: 10, payment_reference: 'ten') }
    let(:invoice_two) { build(:invoice, invoice_number: 20, payment_reference: 'twenty') }
    let(:invoice_three) { build(:invoice, invoice_number: 30, payment_reference: 'threety') }

    it 'should return false if initiator different than auction' do
      result = Notify.invoice_numbers_from_multi_payment(invoice_from_registry)

      expect(result).to be_nil
    end

    it 'should collect invoice numbers from multiple payments with several payments' do
      invoice_one.save
      invoice_one.reload
      invoice_two.save
      invoice_two.reload
      invoice_three.save
      invoice_three.reload

      result = Notify.invoice_numbers_from_multi_payment(multiple_invoice)
      expect(result).to match([{:number=>10, :ref=>"ten"}, {:number=>20, :ref=>"twenty"}, {:number=>30, :ref=>"threety"}])
    end

    it 'should collect invoice numbers from multiple payments with single payment' do
      multiple_invoice.update(description: '10')
      multiple_invoice.reload
      invoice_one.save
      invoice_one.reload

      result = Notify.invoice_numbers_from_multi_payment(multiple_invoice)
      expect(result).to match([{:number=>10, :ref=>"ten"}])
    end

    it 'should be notified that multiple payments have been received' do
      stub_const('ENV', { 'auction_update_payment_url' => 'http://endpoint.auction/get' })

      response = OpenStruct.new(code: 200)

      multiple_invoice.reload
      expect(multiple_invoice.initiator).to eq('auction')

      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint.auction/get'
      uri_object.port = '3000'

      allow(URI).to receive(:parse).and_return(uri_object)
      allow_any_instance_of(Net::HTTP).to receive(:put).and_return(response)

      res = Notify.call(JSON.parse(response_everypay.to_json))

      expect(res.code).to match(200)
    end
  end

  describe 'hash of urls' do
    let(:invoice) { create(:invoice) }

    it 'should return url of registry if initiator is registry' do\
      stub_const('ENV', { 'registry_update_payment_url' => 'http://endpoint.registry/get' })
      invoice.update(initiator: 'registry')
      invoice.reload

      result = Notify.get_update_payment_url[invoice.initiator.to_sym]
      expect(result).to match('http://endpoint.registry/get')
    end

    it 'should return url of auction if initiator is auction' do\
      stub_const('ENV', { 'auction_update_payment_url' => 'http://endpoint.auction/get' })
      invoice.update(initiator: 'auction')
      invoice.reload

      result = Notify.get_update_payment_url[invoice.initiator.to_sym]
      expect(result).to match('http://endpoint.auction/get')
    end

    it 'should return url of eeid if initiator is eeid' do\
      stub_const('ENV', { 'eeid_update_payment_url' => 'http://endpoint.eeid/get' })
      invoice.update(initiator: 'eeid')
      invoice.reload

      result = Notify.get_update_payment_url[invoice.initiator.to_sym]
      expect(result).to match('http://endpoint.eeid/get')
    end
  end

  # describe 'parse'
end
