require 'rails_helper'

RSpec.describe 'EInvoiceResponseSender' do
  invoice_data = {
    invoice_data: {
      id: 92,
      created_at: '2022-02-15T16:46:38.690+02:00',
      updated_at: '2022-02-18T14:50:53.561+02:00',
      due_date: '2022-03-17',
      currency: 'EUR',
      description: 'Direct top-up via bank transfer',
      reference_no: '2144032',
      vat_rate: '20.0',
      seller_name: 'Eesti Interneti SA',
      seller_reg_no: '90010019',
      seller_iban: 'EE557700771000598731',
      seller_bank: 'LHV Pank',
      seller_swift: 'LHVBEE22',
      seller_vat_no: 'EE101286464',
      seller_country_code: 'EE',
      seller_state: 'Harjumaa',
      seller_street: 'Paldiski mnt 80',
      seller_city: 'Tallinn',
      seller_zip: '10617',
      seller_phone: '+372 727 1000',
      seller_url: 'www.internet.ee',
      seller_email: 'info@internet.ee',
      seller_contact_name: 'Martti Õigus',
      buyer_id: 3,
      buyer_name: 'ACCREDITATION EIS',
      buyer_reg_no: '12345623',
      buyer_country_code: 'EE',
      buyer_state: 'Hatjumaa',
      buyer_street: 'Kivila 13',
      buyer_city: 'Tallinn',
      buyer_zip: '12345',
      buyer_phone: '372.35345345',
      buyer_url: 'https://eis.ee',
      buyer_email: 'oleg.hasjanov@eestiinternet.ee',
      creator_str: nil,
      updator_str: 'console-root',
      number: 150_330,
      cancelled_at: nil,
      total: '1.0',
      in_directo: false,
      buyer_vat_no: '123456789',
      issue_date: '2022-02-15',
      e_invoice_sent_at: '2022-02-18T14:50:53.539+02:00',
      payment_link: 'https://igw-demo.every-pay.com/lp?custom_field_1=direct_top-up_via_bank_transfer&custom_field_2=registry&customer_email=oleg.hasjanov@eestiinternet.ee&customer_name=accreditation_eis&invoice_number=150330&linkpay_token=k5t5xq&order_reference=150330&transaction_amount=1.0&hmac=31544c37c49f70b663bd72ceec9917fcd80afd84e5cc4f45da559875cfd6cc06'
    },
    invoice_subtotal: '0.833',
    vat_amount: '0.1666',
    invoice_items: [
      {
        description: 'prepayment',
        price: '0.833',
        quantity: 1,
        unit: 'piece',
        subtotal: '0.833',
        vat_rate: '20.0',
        vat_amount: '0.1666',
        total: '0.9996'
      }
    ],
    payable: false,
    buyer_billing_email: 'eis@eestiinternet.ee',
    buyer_e_invoice_iban: '12345678990',
    seller_country_code: 'EE',
    buyer_country_code: 'EE',
  }

  describe 'e-invoice response handler' do
    it 'should send response after succesfull send invoices to e-invoice' do
      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint/get'
      uri_object.port = '3000'

      allow(URI).to receive(:parse).and_return(uri_object)
      allow(EInvoiceResponseSender).to receive(:get_endpoint_services_e_invoice_url).and_return('http://endpoint/get')
      allow(EInvoiceResponseSender).to receive(:generate_headers).and_return({'header': 'header'})
      expect_any_instance_of(Net::HTTP).to receive(:put).and_return('200 - ok')

      result = EInvoiceResponseSender.send_request(invoice_number: '1')
      expect(result).to eq('200 - ok')
    end
  end
end
