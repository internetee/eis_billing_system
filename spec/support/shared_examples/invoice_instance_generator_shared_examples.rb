RSpec.shared_examples 'generate invoice instance' do
  describe "created invoice instance" do
    it "should generate invoice based on upcoming params from registry" do
      params = {
        invoice_number: "12345",
        custom_field_2: "registry",
        transaction_amount: "23.30"
      }

      expect { InvoiceInstanceGenerator.create(params: params) }.to change { Invoice.count }.by(1)
      expect(Invoice.last.invoice_number).to eq(12345)
      expect(Invoice.last.initiator).to eq("registry")
      expect(Invoice.last.transaction_amount).to eq("23.30")
    end

    it "should generate invoice based on upcoming params from auction" do
      params = {
        invoice_number: "12345",
        custom_field_2: "auction",
        transaction_amount: "23.30"
      }

      expect { InvoiceInstanceGenerator.create(params: params) }.to change { Invoice.count }.by(1)
      expect(Invoice.last.invoice_number).to eq(12345)
      expect(Invoice.last.initiator).to eq("auction")
      expect(Invoice.last.transaction_amount).to eq("23.30")
    end
  end
end
