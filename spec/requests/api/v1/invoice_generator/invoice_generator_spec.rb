require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  params = {
    sum:  '1234',
    name: 'oleg hasjanov',
    description: 'this_is_description',
    invoice_number: '12221'
  }

  it_behaves_like 'Invoice generator', params

  response_ebs = {
    "message" => "PDF File created",
    "status" => "created"
  }

  response_error = {
    "message" => "Parameters missing",
    "status" => "error"
  }

    describe "POST create invoice" do
      it "returns http success" do
        # api_v1_invoice_generator_invoice_generator_index_path
        post "/api/v1/invoice_generator/invoice_generator",
             params: params, headers: { 'Authorization' => "Bearer #{generate_key}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(response_ebs)
      end

      it "should return error if some params are missing" do
          post "/api/v1/invoice_generator/invoice_generator", params: { first_name: 'Oleg', last_name: 'Hasjanov' },
               headers: { 'Authorization' => "Bearer #{generate_key}" }
          expect(JSON.parse(response.body)).to eq(response_error)
      end
    end

  def generate_key
    base_key.encrypt_and_sign(GlobalVariable::INVOICE_SECRET_WORD)
  end

  def base_key
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], Rails.application.secrets.secret_key_base)
  end
end
