require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'searching class method' do
    let(:invoice) { build(:invoice) }
    it 'should find invoice by params' do
      invoice.invoice_number = 22
      invoice.status = 'paid'
      invoice.transaction_amount = 10.0
      invoice.save

      params = {}
      params[:invoice_number] = invoice.invoice_number
      params[:status] = invoice.status
      params[:transaction_amount] = invoice.transaction_amount

      expect(Invoice.search(params)).to include(invoice)
    end
  end
end
