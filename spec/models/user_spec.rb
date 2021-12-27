require 'rails_helper'

RSpec.describe User, type: :model do
  describe "EInvoice" do
    let (:invoice) { build(:invoice) }

    it "should generate EInvoice format data" do
      p invoice.to_e_invoice
    end
  end
end
