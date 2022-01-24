require 'rails_helper'

RSpec.describe "Api::V1::InvoiceGenerator::InvoiceGenerators", type: :request do
  let(:user) { create(:user) }

  it_should_behave_like 'everypay link generator'
  it_should_behave_like 'send billing mail'
end
