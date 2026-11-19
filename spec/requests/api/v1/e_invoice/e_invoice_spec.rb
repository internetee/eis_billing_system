require 'rails_helper'

RSpec.describe "Api::V1::EInvoice::EInvoices", type: :request do
  describe "SendEInvoiceJob" do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it "enqueues the job and responds without waiting for Omniva" do
      ActiveJob::Base.queue_adapter = :test
      expect_any_instance_of(EInvoiceGenerator).not_to receive(:generate)

      params = {
        "invoice" => { "id" => "1", "number" => "144677" },
        "invoice_subtotal" => "invoice_subtotal",
        "vat_amount" => "vat_amount",
        "items" => [{ "description" => "prepayment", "price" => "100.0" }],
        "payable" => "payable",
        "buyer_billing_email" => "buyer_billing_email",
        "buyer_e_invoice_iban" => "buyer_e_invoice_iban",
        "seller_country_code" => "seller_country_code",
        "buyer_country_code" => "buyer_country_code",
        "initiator" => "initiator"
      }

      expect { post api_v1_e_invoice_e_invoice_index_path, params: params }
        .to have_enqueued_job(SendEInvoiceJob)

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)["message"]).to eq('Invoice data received')
    end
  end
end
