require 'rails_helper'

RSpec.describe "InvoiceGenerators" do
  params = {
    invoice_number: "125",
    custom_field_2: "registry",
    transaction_amount: "23.30"
  }

  it_behaves_like 'invoice generator', params
end
