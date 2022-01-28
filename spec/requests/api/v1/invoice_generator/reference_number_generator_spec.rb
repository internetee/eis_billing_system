require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::ReferenceNumberGenerators", type: :request do
  let(:reference) { build(:reference) }

  describe "POST /create" do
    it "should return reference number" do
      allow(Billing::ReferenceNo).to receive(:generate).and_return('001')

      post api_v1_invoice_generator_reference_number_generator_index_url, params: { initiator: 'registry' }

      reference_number = JSON.parse(response.body)['reference_number']

      expect(response).to have_http_status(:success)
      expect(reference_number).to eq('001')
    end

    it "should create a record in reference table" do
      allow(Billing::ReferenceNo).to receive(:generate).and_return('233')

      expect(Reference.count).to eq(0)

      post api_v1_invoice_generator_reference_number_generator_index_url, params: { initiator: 'registry' }

      expect(response).to have_http_status(:success)
      expect(Reference.count).to eq(1)

      reference = Reference.last
      expect(reference.initiator).to eq('registry')
      expect(reference.reference_number).to eq(233)
    end

    it "should return reference number without zeros in first positions" do
      allow(Billing::ReferenceNo).to receive(:generate).and_return('000233')

      expect(Reference.count).to eq(0)

      post api_v1_invoice_generator_reference_number_generator_index_url, params: { initiator: 'registry' }

      expect(response).to have_http_status(:success)
      expect(Reference.count).to eq(1)

      reference = Reference.last
      expect(reference.initiator).to eq('registry')
      expect(reference.reference_number).to eq(233)
    end
  end
end
