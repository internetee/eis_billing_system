require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  params = {
    invoice_number: "125",
    custom_field_2: "registry",
    transaction_amount: "23.30"
  }

  before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

  it "should generate invoice instance" do
    expect { InvoiceInstanceGenerator.create(params: params) }.to change { Invoice.count }.by(1)
  end

  it "should generate invoice link" do
    expect_any_instance_of(EverypayLinkGenerator).to receive(:build_link).and_return('http://everypay.link')

    link = EverypayLinkGenerator.create(params: params)
    expect(link).to eq('http://everypay.link')
  end
end

