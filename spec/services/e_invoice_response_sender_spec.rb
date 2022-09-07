require 'rails_helper'

RSpec.describe 'EInvoiceResponseSender' do
  describe 'e-invoice response handler' do
    it 'should send response after succesfull send invoices to e-invoice' do
      # einvoice_response = {
      #   message: '200 - ok'
      # }
      # stub_request(:put, "http://registry:3000/eis_billing/e_invoice_response")
      # .to_return(status: 200, body: einvoice_response.to_json, headers: {})

      # result = EInvoiceResponseSender.send_request(invoice_number: '1')

      # expect(result['message']).to eq('200 - ok')
    end
  end
end
