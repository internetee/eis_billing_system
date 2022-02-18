RSpec.shared_examples 'should send invoices to directo' do |_params|
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  response = OpenStruct.new

  xml_response = <<-XML
  <?xml version="1.0" encoding="UTF-8"?>
    <results>
      <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
    </results>
  XML

  response.body = xml_response

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
      'seller_vat_no' => nil,
      'seller_country_code' => 'US',
      'seller_state' => nil,
      'seller_street' => 'Main Street 1',
      'seller_city' => 'New York',
      'seller_zip' => nil,
      'seller_phone' => nil,
      'seller_url' => nil,
      'seller_email' => 'info@seller.test',
      'seller_contact_name' => 'John Doe',
      'buyer_id' => 901_064_816,
      'buyer_name' => 'Buyer Ltd',
      'buyer_reg_no' => '12345',
      'buyer_country_code' => 'GB',
      'buyer_state' => nil,
      'buyer_street' => 'Main Street 2',
      'buyer_city' => 'London',
      'buyer_zip' => nil,
      'buyer_phone' => nil,
      'buyer_url' => nil,
      'buyer_email' => 'info@buyer.test',
      'creator_str' => nil,
      'updator_str' => nil,
      'number' => 1,
      'cancelled_at' => nil,
      'total' => '1.0',
      'in_directo' => false,
      'buyer_vat_no' => nil,
      'issue_date' => '2010-07-05',
      'e_invoice_sent_at' => nil,
      'payment_link' => nil,
      'customer' => { 'code' => 'bestnames',
                      'destination' => 'GB',
                      'vat_reg_no' => nil },
      'transaction_date' => '2010-08-06',
      'language' => 'ENG',
      'invoice_lines' => [{ 'product_id' => 'ETTEM06', 'description' => 'Order nr. 1', 'quantity' => 1,
                            'price' => '5.00' }]
    }
  ]

  describe '#perform - send_receipts' do
    it 'DirectoResponseSender should get respose' do
      directo_client = OpenStruct.new

      class DirectoClientInvoice
        def add_with_schema(invoice:, schema:)
          true
        end

        def as_xml
          <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
              <results>
                <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
              </results>
          XML
        end

        def deliver(ssl_verify: false)
          response = OpenStruct.new
          response.body = <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
              <results>
                <Result Type="0" Desc="OK" docid="309902" doctype="ARVE" submit="Invoices"/>
              </results>
          XML

          response
        end
      end

      directo_client_invoice = DirectoClientInvoice.new
      directo_client.invoices = directo_client_invoice

      allow_any_instance_of(DirectoInvoiceForwardJob).to receive(:new_directo_client).and_return(directo_client)
      DirectoInvoiceForwardJob.perform_now(invoice_data: directo_invoice_json, initiator: 'registry')
    end
  end
end
