RSpec.shared_examples 'should notify initiator' do |response_everypay|
  let(:invoice) { create(:invoice) }
  let(:invoice_s) { create(:invoice, invoice_number: 4) }

  before(:each) do
    stub_const('ENV', { 'update_payment_url' => 'http://endpoint:3000/get' })
    stub_const('ENV', { 'registry_update_payment_url' => 'http://endpoint/get' })
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

    expect(res).to match(200)
  end

  it 'should notify auction that multiply invoices were paid' do

  end
end
