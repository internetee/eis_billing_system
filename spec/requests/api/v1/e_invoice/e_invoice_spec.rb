require 'rails_helper'

RSpec.describe "Api::V1::EInvoice::EInvoices", type: :request do
  describe "SendEInvoiceJob" do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it "should initiate to run job" do
      allow_any_instance_of(SendEInvoiceJob).to receive(:perform_now).and_return(true)

      params = {
        "invoice" => "invoice",
        "invoice_subtotal" => "invoice_subtotal",
        "vat_amount" => "vat_amount",
        "items" => "items",
        "payable" => "payable",
        "buyer_billing_email" => "buyer_billing_email",
        "buyer_e_invoice_iban" => "buyer_e_invoice_iban",
        "seller_country_code" => "seller_country_code",
        "buyer_country_code" => "buyer_country_code",
        "initiator" => "initiator"
      }

      post api_v1_e_invoice_e_invoice_index_path, params: params

      res = JSON.parse(response.body)
      expect(res["message"]).to eq('Invoice data received')
    end
  end
end
