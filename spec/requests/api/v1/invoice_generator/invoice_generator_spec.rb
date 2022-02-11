require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  params = {
    invoice_number: "125",
    custom_field_2: "registry",
    transaction_amount: "23.30"
  }

  it_behaves_like 'invoice generator', params

  describe "POST /create" do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it "should return success response" do
      post api_v1_invoice_generator_invoice_generator_index_url, params: params

      expect(response).to have_http_status(:success)
    end
  end
end
