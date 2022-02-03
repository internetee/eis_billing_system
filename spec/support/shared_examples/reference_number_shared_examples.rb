RSpec.shared_examples 'reference number generator' do
  let(:reference) { build(:reference) }

  describe "Refrence number generator" do
    it "generates random base" do
      expect(Billing::ReferenceNo.generate).not_to eq(Billing::ReferenceNo.generate)
    end

    it "randomly generated base conforms to standard" do
      base = Billing::ReferenceNo::Base.generate
      format = /\A\d{1,19}\z/
      expect(format).to match(base.to_s)
    end

    it "generates check digit for a given base" do
      expect(Billing::ReferenceNo::Base.new('1').check_digit).to eq(3)
      expect(Billing::ReferenceNo::Base.new('1234567891234567891').check_digit).to eq(7)
      expect(Billing::ReferenceNo::Base.new('773423').check_digit).to eq(0)
    end

    it "returns string representation" do
      base = Billing::ReferenceNo::Base.new('1')
      expect(base.to_s).to eq('1')
    end

    it "normalizes non string values" do
      base = Billing::ReferenceNo::Base.new(1)
      expect(base.to_s).to eq('1')
    end
  end
end
