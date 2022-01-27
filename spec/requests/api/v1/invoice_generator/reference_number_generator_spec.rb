require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::ReferenceNumberGenerators", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/invoice_generator/reference_number_generator/create"
      expect(response).to have_http_status(:success)
    end
  end

end
