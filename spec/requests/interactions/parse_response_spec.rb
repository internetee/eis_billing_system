require 'rails_helper'

RSpec.describe "ParseResponse" do
  let(:invoice) { create(:invoice) }
  let(:user) { create(:user) }

  it_should_behave_like 'should notify all callback observers'

  it 'if call describer_class should notify observers' do
    response = {
      "account_name" => "EUR",
      "order_reference" => "#{invoice.invoice_number}",
      "email" => "#{user.email}",
      "customer_ip" => "12.32.12.12",
      "customer_url" => 'http://eis.ee',
      "payment_created_at" => "#{Time.zone.now - 10.hours}",
      "initial_amount" => "123.32",
      "standing_amount" => "123.32",
      "payment_reference" => "234343423423423asd",
      "payment_link" => "http://everypay.link",
      "api_username" => "some-api",
      "warnings" => [],
      "stan" => "stab",
      "fraud_score" => 'fraud_score',
      "payment_state" => 'settled',
      "payment_method" => 'everypay',
      "ob_details" => 'ob_details',
      "creditor_iban" => '23323123323123',
      "ob_payment_reference" => '213123123',
      "ob_payment_state" => '213123123',
      "transaction_time" => "#{Time.zone.now - 1.hour}",
    }

    uri_object = OpenStruct.new
    uri_object.host = 'http://endpoint/get'
    uri_object.port = '3000'

    allow(URI).to receive(:parse).and_return(uri_object)
    expect_any_instance_of(Net::HTTP).to receive(:put).and_return('200 - ok')

    ParseResponse.call(response)
  end

end
