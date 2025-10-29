require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'validations and callbacks' do
    it 'has defaults and is valid with factory' do
      invoice = build(:invoice)
      expect(invoice).to be_valid
      expect(Invoice.statuses.keys).to include('unpaid')
      expect(Invoice.affiliations.keys).to include('regular')
    end

    it 'has enum values for status' do
      expect(Invoice.statuses.keys).to include('unpaid', 'paid', 'cancelled', 'failed', 'refunded', 'overdue')
    end

    it 'has enum values for affiliation' do
      expect(Invoice.affiliations.keys).to include('regular', 'auction_deposit', 'linkpay')
    end
  end

  describe 'scopes' do
    let!(:paid_invoice) { create(:invoice, status: :paid, transaction_amount: 10.0) }
    let!(:unpaid_invoice) { create(:invoice, status: :unpaid, transaction_amount: 20.0) }

    it 'filters by status' do
      results = Invoice.with_status('paid')
      expect(results).to include(paid_invoice)
      expect(results).not_to include(unpaid_invoice)
    end

    it 'filters by amount range' do
      results = Invoice.with_amount_between(15, 25)
      expect(results).to include(unpaid_invoice)
      expect(results).not_to include(paid_invoice)
    end
  end
end
