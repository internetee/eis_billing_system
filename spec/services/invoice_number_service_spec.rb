require 'rails_helper'

RSpec.describe InvoiceNumberService do
  before do
    Invoice.delete_all
  end

  let(:deposit_min_num) { Setting.invoice_number_auction_deposit_min || ENV['deposit_min_num'].to_i }
  let(:deposit_max_num) { Setting.invoice_number_auction_deposit_max || ENV['deposit_max_num'].to_i }
  let(:min_num) { Setting.invoice_number_min || 150_005 }
  let(:max_num) { Setting.invoice_number_max || 199_999 }

  describe '.call' do
    context 'with regular invoice numbers' do
      it 'returns minimum number when no invoices exist' do
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_005)
      end

      it 'returns next sequential number' do
        Invoice.create!(invoice_number: min_num.to_s, initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_006)
      end

      it 'finds highest number in range and increments' do
        Invoice.create!(invoice_number: min_num + 5, initiator: 'auction', transaction_amount: '10.0')
        Invoice.create!(invoice_number: min_num, initiator: 'auction', transaction_amount: '10.0')
        Invoice.create!(invoice_number: min_num + 2, initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_011)
      end

      it 'ignores numbers outside range' do
        Invoice.create!(invoice_number: min_num + 5, initiator: 'auction', transaction_amount: '10.0')
        Invoice.create!(invoice_number: max_num + 1, initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(min_num + 6)
      end
    end

    context 'with auction deposit invoice numbers' do
      it 'uses auction deposit range' do
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(deposit_min_num)
      end

      it 'increments within auction deposit range' do
        Invoice.create!(invoice_number: deposit_min_num.to_s, initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(deposit_min_num + 1)
      end

      it 'ignores regular invoice numbers when generating auction deposit numbers' do
        Invoice.create!(invoice_number: min_num.to_s, initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: true)
        expect(number).to eq(deposit_min_num)
      end
    end

    context 'edge cases' do
      it 'handles string invoice numbers correctly' do
        Invoice.create!(invoice_number: '150005', initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_006)
      end

      it 'handles non-numeric invoice numbers' do
        Invoice.create!(invoice_number: 'INVALID', initiator: 'auction', transaction_amount: '10.0')
        number = described_class.call(invoice_auction_deposit: false)
        expect(number).to eq(150_005)
      end
    end
  end
end
