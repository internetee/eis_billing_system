RSpec.shared_examples 'should notify initiator' do |response_everypay|
  let(:invoice) { create(:invoice) }

  before(:each) do
    stub_const('ENV', {'update_payment_url' => 'http://endpoint:3000/get'})
  end

  it 'should notify registrar that response was receive in callback handler' do
    invoice.save
    expect(invoice.initiator).to eq('registry')

    uri_object = OpenStruct.new
    uri_object.host = 'http://endpoint/get'
    uri_object.port = '3000'

    allow(URI).to receive(:parse).and_return(uri_object)
    expect_any_instance_of(Net::HTTP).to receive(:put).and_return('200 - ok')

    res = Notify.call(JSON.parse(response_everypay.to_json))
    # allow(Notify).to receive(:update_payment_url).with(initiator: 'registry').and_return('registry')

    # expect(Notify.update_payment_url).to eq('registry')
    expect(res).to match('200 - ok')
  end
end
