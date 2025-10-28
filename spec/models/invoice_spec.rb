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

    it 'return true if invoice related to auction prepayment deposit case' do
      invoice.update(description: 'auction_deposit test.ee, user_uuid sdfsdfsdf, user_email test@test.ee')
      invoice.reload

      expect(invoice.auction_deposit_prepayment?).to eq true
    end

    it 'should send data for synchronization and get success result' do
      mock_response = {
        'message' => 'Invoice data was successfully updated'
      }
      allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)

      response = invoice.synchronize(status: 'paid')

      expect(response.result?).to eq true
    end

    it 'should send data for synchronization and get error' do
      mock_response = {
        'error' => {
          'message' => 'Something went wrong'
        }
      }
      allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)

      response = invoice.synchronize(status: 'paid')

      expect(response.result?).to eq false
    end
  end

  describe 'predicate methods' do
    let(:invoice) { create(:invoice) }

    it 'checks auction_deposit_prepayment correctly' do
      invoice.update(description: 'auction_deposit domain example.com')
      expect(invoice.auction_deposit_prepayment?).to be true

      invoice.update(description: 'regular payment')
      expect(invoice.auction_deposit_prepayment?).to be false

      invoice.update(description: nil)
      expect(invoice.auction_deposit_prepayment?).to be false
    end

    it 'checks initiator types' do
      invoice.update(initiator: 'registry')
      expect(invoice.registry?).to be true
      expect(invoice.billing_system?).to be false

      invoice.update(initiator: 'billing_system')
      expect(invoice.billing_system?).to be true
      expect(invoice.registry?).to be false
    end
  end

  describe '#to_h' do
    it 'returns hash with all attributes' do
      invoice = create(:invoice, invoice_number: '123', initiator: 'registry', status: :paid)
      hash = invoice.to_h
      expect(hash[:invoice_number].to_s).to eq('123')
      expect(hash[:initiator]).to eq('registry')
      expect(hash[:status]).to eq('paid')
    end
  end
end
