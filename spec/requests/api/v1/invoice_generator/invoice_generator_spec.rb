require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  let(:user) { create(:user) }
  let(:invoice) { create(:invoice) }

  it_behaves_like 'Invoice generator', '12233'

  response_ebs = {
    "message" => "PDF File created",
    "status" => "created"
  }

  response_error = {
    "message" => "Parameters missing",
    "status" => "error"
  }

    describe "POST create invoice response" do
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

  describe "generate invoice instance" do
    it "should successfully create invoice instance" do
      expect(Invoice.all.count).to be 0
      post "/api/v1/invoice_generator/invoice_generator",
           params: params(reference_number: '123', buyer_name: 'Ruslan'),
           headers: { 'Authorization' => "Bearer #{generate_key}" }

      expect(Invoice.all.count).to be 1
      expect(Invoice.last.buyer_name).to eq 'Ruslan'
      expect(Invoice.last.reference_number).to eq '123'
    end
  end

  def params(reference_number: '12233', buyer_name: 'Oleg')
    {
      reference_number: reference_number,

      description:  'this is description',
      currency: 'EUR',
      invoice_number: '12332',
      transaction_amount: '1000',
      seller_name: 'EIS',
      seller_reg_no: '122',
      seller_iban: '34234234234424',
      seller_bank: 'LHV',
      seller_swift: '1123344',
      seller_vat_no: '23321',
      seller_country_code: 'EE',
      seller_state: 'Harjumaa',
      seller_street: 'Paldiski mnt',
      seller_city: 'Tallinn',
      seller_zip: '223323',
      seller_phone: '+372.342342',
      seller_url: 'eis.ee',
      seller_email: 'eis@internet.ee',
      seller_contact_name: 'Eesti Internet SA',
      buyer_name: buyer_name,
      buyer_reg_no: '324344',
      buyer_country_code: 'EE',
      buyer_state: 'Harjumaa',
      buyer_street: 'Kivila',
      buyer_city: 'Tallinn',
      buyer_zip: '13919',
      buyer_phone: '+372.59813318',
      buyer_url: 'n-brains.com',
      buyer_email: 'oleg.hasjanov@eestiinternet.ee',
      vat_rate: '20',
      role: 'private_user',
      buyer_vat_no: '23323',
      buyer_iban: '4454322423432'
    }
  end

  def generate_key
    base_key.encrypt_and_sign(GlobalVariable::INVOICE_SECRET_WORD)
  end

  def base_key
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], Rails.application.secrets.secret_key_base)
  end
end
