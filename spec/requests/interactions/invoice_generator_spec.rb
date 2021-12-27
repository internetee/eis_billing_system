require 'rails_helper'

RSpec.describe "InvoiceGenerators" do
  params = {
    sum:  '1234',
    name: 'oleg hasjanov',
    description: 'this_is_description',
    invoice_number: '12221'
  }

  it_behaves_like 'Invoice generator', params
end
