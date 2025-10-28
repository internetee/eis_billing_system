require 'rails_helper'

RSpec.describe InvoiceNumberService do
  before do
    Invoice.delete_all
  end

  describe '.call' do
    context 'with regular invoice numbers' do
      it 'returns minimum number when no invoices exist' do
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_005)
      end

      it 'returns next sequential number' do
        Invoice.create!(invoice_number: '150005', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_006)
      end

      it 'finds highest number in range and increments' do
        Invoice.create!(invoice_number: '150010', initiator: 'test', transaction_amount: '10.0')
        Invoice.create!(invoice_number: '150005', initiator: 'test', transaction_amount: '10.0')
        Invoice.create!(invoice_number: '150008', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_011)
      end

      it 'ignores numbers outside range' do
        Invoice.create!(invoice_number: '150010', initiator: 'test', transaction_amount: '10.0')
        Invoice.create!(invoice_number: '200000', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_011)
      end
    end

    context 'with auction deposit invoice numbers' do
      it 'uses auction deposit range' do
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(10_001)
      end

      it 'increments within auction deposit range' do
        Invoice.create!(invoice_number: '10001', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(10_002)
      end

      it 'ignores regular invoice numbers when generating auction deposit numbers' do
        Invoice.create!(invoice_number: '150010', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(10_001)
      end
    end

    context 'edge cases' do
      it 'handles string invoice numbers correctly' do
        Invoice.create!(invoice_number: '150005', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_006)
      end

      it 'handles non-numeric invoice numbers' do
        Invoice.create!(invoice_number: 'INVALID', initiator: 'test', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_005)
      end
    end
  end
end
