require 'rails_helper'

RSpec.describe 'DirectoInvoiceForwardJob', type: :job do
  directo_invoice_json = [
    {
      'id' => 980_190_962,
      'created_at' => '2022-02-01T11:47:17.916+02:00',
      'updated_at' => '2010-08-06T00:00:00.000+03:00',
      'due_date' => '2010-07-06',
      'currency' => 'EUR',
      'description' => 'Order nr 1 from registrar 1234567 second number 2345678',
      'reference_no' => '13',
      'vat_rate' => '10.0',
      'seller_name' => 'Seller Ltd',
      'seller_reg_no' => '1234',
      'seller_iban' => 'US75512108001245126199',
      'seller_bank' => 'Main Bank',
      'seller_swift' => 'swift',
      'seller_vat_no' => 'EE101286464',
      'seller_country_code' => 'US',
      'seller_state' => 'Harjumaa',
      'seller_street' => 'Main Street 1',
      'seller_city' => 'New York',
      'seller_zip' => '23324',
      'seller_phone' => '372.35345345',
      'seller_url' => 'https://n-brains.com',
      'seller_email' => 'info@seller.test',
      'seller_contact_name' => 'John Doe',
      'buyer_id' => 2,
      'buyer_name' => 'Buyer Ltd',
      'buyer_reg_no' => '12345',
      'buyer_country_code' => 'GB',
      'buyer_state' => 'Harjumaa',
      'buyer_street' => 'Main Street 2',
      'buyer_city' => 'London',
      'buyer_zip' => '23324',
      'buyer_phone' => '372.35345345"',
      'buyer_url' => 'https://n-brains.com"',
      'buyer_email' => 'info@buyer.test',
      'creator_str' => '2-ApiUser: oleghasjanov',
      'updator_str' => nil,
      'number' => 1,
      'cancelled_at' => nil,
      'total' => '1.0',
      'in_directo' => false,
      'buyer_vat_no' => '123456789',
      'issue_date' => '2010-07-05',
      'e_invoice_sent_at' => Time.zone.now - 30.minutes,
      'payment_link' => 'http://payment.link',
      'customer' => { 'code' => 'bestnames',
                      'destination' => 'GB',
                      'vat_reg_no' => '123456789' },
      'transaction_date' => '2010-08-06',
      'language' => 'ENG',
      'invoice_lines' => [{ 'product_id' => 'ETTEM06', 'description' => 'Order nr. 1', 'quantity' => 1,
                            'price' => '5.00' }]
    }
  ]

  let!(:admin) { create(:user) }
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.delivery_method = :test
  end

  describe 'error handler' do
    it 'should notify if StandardError occur' do
      expect { DirectoInvoiceForwardJob.perform_now(invoice_data: 'some', initiator: 'registry')}
              .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe '#perform - send_receipts' do
    let(:invoice) { create(:invoice) }

    it 'DirectoResponseSender should get respose' do
      directo_client = OpenStruct.new

      class DirectoClientInvoice
        def initialize(invoice_id)
          @invoice_id = invoice_id
        end

        def add_with_schema(invoice:, schema:)
          true
        end

        def as_xml
          <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
              <results>
                <Result Type="0" Desc="OK" docid="#{@invoice_id}" doctype="ARVE" submit="Invoices"/>
              </results>
          XML
        end

        def deliver(ssl_verify: false)
          response = OpenStruct.new
          response.body = as_xml

          response
        end

        def count
          1
        end
      end

      directo_client_invoice = DirectoClientInvoice.new(invoice.id)
      directo_client.invoices = directo_client_invoice

      stub_request(:put, "http://registry:3000/eis_billing/directo_response")
         .to_return(status: 200, body: directo_client_invoice.as_xml.to_json, headers: {})
      stub_request(:put, "http://auction_center:3000/eis_billing/directo_response")
         .to_return(status: 200, body: directo_client_invoice.as_xml.to_json, headers: {})
      stub_request(:put, "http://eeid:3000/eis_billing/directo_response")
         .to_return(status: 200, body: directo_client_invoice.as_xml.to_json, headers: {})

      allow_any_instance_of(DirectoInvoiceForwardJob).to receive(:new_directo_client).and_return(directo_client)
      DirectoInvoiceForwardJob.perform_now(invoice_data: directo_invoice_json, initiator: 'registry')

      allow_any_instance_of(DirectoInvoiceForwardJob).to receive(:new_directo_client).and_return(directo_client)
      DirectoInvoiceForwardJob.perform_now(invoice_data: directo_invoice_json, initiator: 'auction')

      allow_any_instance_of(DirectoInvoiceForwardJob).to receive(:new_directo_client).and_return(directo_client)
      DirectoInvoiceForwardJob.perform_now(invoice_data: directo_invoice_json, initiator: 'eeid')
    end
  end
end
