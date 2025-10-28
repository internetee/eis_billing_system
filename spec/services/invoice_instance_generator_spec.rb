require 'rails_helper'

RSpec.describe InvoiceInstanceGenerator do
  describe '.create' do
    it 'creates regular unpaid invoice by default' do
      invoice = described_class.create(params: {
        invoice_number: '100',
        custom_field2: 'registry',
        transaction_amount: '10.0'
      })
      expect(invoice).to be_persisted
      expect(invoice.affiliation).to eq('regular')
      expect(invoice.status).to eq('unpaid')
      expect(invoice.initiator).to eq('registry')
      expect(invoice.invoice_number.to_s).to eq('100')
      expect(invoice.description).to eq('reload balance')
    end

    it 'creates auction_deposit affiliation when provided' do
      invoice = described_class.create(params: {
        invoice_number: '101',
        custom_field2: 'auction',
        transaction_amount: '0.0',
        affiliation: 'auction_deposit',
        custom_field1: 'deposit topup'
      })
      expect(invoice.affiliation).to eq('auction_deposit')
      expect(invoice.status).to eq('paid')
      expect(invoice.description).to eq('deposit topup')
    end
  end
end

require 'rails_helper'

RSpec.describe "InvoiceInstanceGenerator" do
  it_behaves_like 'generate invoice instance'
end