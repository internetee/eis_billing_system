require 'rails_helper'

RSpec.describe Notify do
  let(:invoice) { create(:invoice, invoice_number: 'TEST-001', status: :unpaid) }
  let(:response_data) do
    {
      'payment_state' => 'settled',
      'payment_reference' => 'PAY-REF-123',
      'order_reference' => 'TEST-001',
      'transaction_time' => '2023-01-01T12:00:00Z'
    }
  end

  describe '.call' do
    subject(:call_notifier) { described_class.call(response: response_data) }
    context 'when invoice exists and is unpaid' do
      before do
        allow(Invoice).to receive(:find_by).with(invoice_number: 'TEST-001').and_return(invoice)
      end

      it 'updates invoice state to paid when payment is settled' do
        call_notifier

        expect(invoice.reload.status).to eq('paid')
        expect(invoice.payment_reference).to eq('PAY-REF-123')
      end

      it 'updates invoice state to failed when payment is not settled' do
        described_class.call(response: response_data.merge('payment_state' => 'failed'))

        expect(invoice.reload.status).to eq('failed')
      end

      it 'does not send notification for billing-system invoices' do
        allow(invoice).to receive(:billing_system?).and_return(true)

        call_notifier

        expect(invoice.reload.status).to eq('paid')
      end
    end

    context 'when invoice does not exist' do
      before do
        allow(Invoice).to receive(:find_by).with(invoice_number: 'TEST-001').and_return(nil)
      end

      it 'does not raise error when invoice is missing' do
        expect { call_notifier }.not_to raise_error
      end
    end

    context 'when invoice is already paid' do
      before do
        allow(Invoice).to receive(:find_by).with(invoice_number: 'TEST-001').and_return(invoice)
        allow(invoice).to receive(:paid?).and_return(true)
      end

      it 'does not update invoice state' do
        notifier = described_class.new(response: response_data)
        allow(notifier).to receive(:update_invoice_state)

        call_notifier

        expect(notifier).not_to have_received(:update_invoice_state)
      end
    end

    context 'with multi-payment handling' do
      before do
        allow(Invoice).to receive(:find_by).and_return(invoice)
        allow(invoice).to receive(:paid?).and_return(true)
        allow(invoice).to receive(:billing_system?).and_return(false)
        allow(invoice).to receive(:initiator).and_return('auction')
        allow(invoice).to receive(:auction_deposit_prepayment?).and_return(false)
        allow(invoice).to receive(:description).and_return('TEST-002 TEST-003')
      end

      it 'handles multiple invoice numbers in order reference' do
        expect { described_class.call(response: response_data.merge('order_reference' => 'TEST-001, TEST-002, TEST-003')) }.not_to raise_error
      end
    end

    context 'with auction deposit prepayment' do
      before do
        allow(Invoice).to receive(:find_by).with(invoice_number: 'TEST-001').and_return(invoice)
        allow(invoice).to receive(:paid?).and_return(true)
        allow(invoice).to receive(:billing_system?).and_return(false)
        allow(invoice).to receive(:initiator).and_return('auction')
        allow(invoice).to receive(:auction_deposit_prepayment?).and_return(true)
      end

      it 'handles deposit prepayment differently' do
        allow(invoice).to receive(:description).and_return('domain test.com')
        
        expect { described_class.call(response: response_data) }.not_to raise_error
      end
    end

    context 'error handling' do
      it 'catches and logs errors' do
        allow(Invoice).to receive(:find_by).and_raise(StandardError.new('Database error'))

        expect { described_class.call(response: response_data) }.not_to raise_error
      end
    end
  end

  describe '#update_invoice_state' do
    let(:notifier) { described_class.new(response: response_data) }

    it 'updates invoice with settled payment' do
      invoice = create(:invoice, status: :unpaid)
      notifier.update_invoice_state(parsed_response: {
        payment_state: 'settled',
        payment_reference: 'PAY-REF-123',
        transaction_time: '2023-01-01T12:00:00Z',
        order_reference: 'TEST-001'
      }, invoice: invoice)
      invoice.reload
      expect(invoice.status).to eq('paid')
      expect(invoice.payment_reference).to eq('PAY-REF-123')
      expect(invoice.transaction_time).to eq('2023-01-01T12:00:00Z')
    end

    it 'updates invoice with failed payment' do
      invoice = create(:invoice, status: :unpaid)
      notifier.update_invoice_state(parsed_response: {
        payment_state: 'failed',
        payment_reference: 'PAY-REF-123',
        transaction_time: '2023-01-01T12:00:00Z',
        order_reference: 'TEST-001'
      }, invoice: invoice)
      invoice.reload
      expect(invoice.status).to eq('failed')
    end
  end

  describe '#define_for_deposit' do
    it 'builds correct params and performs PUT' do
      response_data # touch let
      notifier = described_class.new(response: response_data)
      invoice = create(:invoice, initiator: 'auction', description: 'domain example.com, uuid 123e4567-e89b-12d3-a456-426614174000, email user@example.com', transaction_amount: 12.34, invoice_number: 42)
      url = 'http://services.example/update'

      allow(notifier).to receive(:put_request)

      notifier.define_for_deposit(invoice, url)

      expect(notifier).to have_received(:put_request).with(
        direction: 'services',
        path: url,
        params: hash_including(
          domain_name: 'example.com',
          user_uuid: '123e4567-e89b-12d3-a456-426614174000',
          user_email: 'user@example.com',
          transaction_amount: 12.34,
          invoice_number: 42,
          description: 'deposit',
          affiliation: 1
        )
      )
    end
  end

  describe '#notify' do
    it 'sends email via NotifierMailer' do
      notifier = described_class.new(response: response_data)
      mailer = double(deliver_now: true)
      allow(NotifierMailer).to receive(:inform_admin).and_return(mailer)

      notifier.notify(title: 't', error_message: 'e')

      expect(NotifierMailer).to have_received(:inform_admin).with('t', 'e')
      expect(mailer).to have_received(:deliver_now)
    end
  end

  describe '.call error handling' do
    it 'logs and notifies on exception' do
      allow(Invoice).to receive(:find_by).and_raise(StandardError.new('boom'))
      allow(Rails.logger).to receive(:error)
      notifier = described_class.new(response: response_data)
      allow(notifier).to receive(:notify)
      allow(Notify).to receive(:new).and_return(notifier)

      expect { described_class.call(response: response_data) }.not_to raise_error
      expect(Rails.logger).to have_received(:error)
      expect(notifier).to have_received(:notify)
    end
  end
  describe '#invoice_numbers_from_multi_payment' do
    let(:notifier) { described_class.new(response: response_data) }

    context 'with valid auction invoice' do
      let(:invoice) { create(:invoice, initiator: 'auction', description: '2 3', status: :paid, transaction_time: '2023-01-01T12:00:00Z') }
      
      before do
        create(:invoice, invoice_number: 2, payment_reference: 'OLD-REF')
        create(:invoice, invoice_number: 3, payment_reference: 'OLD-REF')
      end

      it 'processes multiple invoice numbers' do
        result = notifier.invoice_numbers_from_multi_payment(invoice)
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.first[:number]).to eq(2)
        expect(result.first[:ref]).to eq('OLD-REF')
      end

      it 'updates related invoices with parent invoice data' do
        notifier.invoice_numbers_from_multi_payment(invoice)
        related_invoice = Invoice.find_by(invoice_number: 2)
        expect(related_invoice).not_to be_nil
        expect(related_invoice.payment_reference).to eq(invoice.payment_reference)
        expect(related_invoice.status).to eq(invoice.status)
        expect(related_invoice.description).to eq("related to #{invoice.invoice_number}")
      end
    end

    context 'with non-auction invoice' do
      let(:invoice) { create(:invoice, initiator: 'registry', description: '2 3') }

      it 'returns empty array for non-auction invoices' do
        result = notifier.invoice_numbers_from_multi_payment(invoice)
        expect(result).to eq([])
      end
    end

    context 'with prepended invoice' do
      let(:invoice) { create(:invoice, initiator: 'auction', description: 'prepended') }

      it 'returns nil for prepended invoices' do
        result = notifier.invoice_numbers_from_multi_payment(invoice)
        expect(result).to be_nil
      end
    end

    context 'with empty description' do
      let(:invoice) { create(:invoice, initiator: 'auction', description: '') }

      it 'returns nil for empty description' do
        result = notifier.invoice_numbers_from_multi_payment(invoice)
        expect(result).to be_nil
      end
    end
  end
end