require 'rails_helper'

RSpec.describe "Api::V1::Directo::Directos", type: :request do
  describe "DirectoInvoiceForwardJob" do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it "should initiate to run job" do
      allow_any_instance_of(DirectoInvoiceForwardJob).to receive(:perform_now).and_return(true)

      params = {
        "invoice_data" => "invoice_data",
        "dry" => "dry",
        "monthly" => "monthly",
        "initiator" => "initiator"
      }

      post api_v1_directo_directo_index_path, params: params

      res = JSON.parse(response.body)
      expect(res["message"]).to eq('Invoice data received')
    end
  end
end
