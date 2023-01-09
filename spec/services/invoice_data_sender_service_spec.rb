require 'rails_helper'

RSpec.describe 'InvoiceDataSenderService' do
  describe 'indeticate to whom send invoices' do
    let(:invoice) { create(:invoice) }

    it 'should send invoice data to registry' do
      invoice.initiator = 'registry'
      invoice.save && invoice.reload

      expect(invoice.initiator).to eq 'registry'

      invoice_sender = InvoiceDataSenderService.new(invoice: invoice)
      initiator = invoice_sender.send(:to_whom)

      expect(initiator).to eq "#{GlobalVariable::BASE_REGISTRY}/eis_billing/invoices"
    end

    it 'should send invoice data to auction' do
      invoice.initiator = 'auction'
      invoice.save && invoice.reload

      expect(invoice.initiator).to eq 'auction'

      invoice_sender = InvoiceDataSenderService.new(invoice: invoice)
      initiator = invoice_sender.send(:to_whom)

      expect(initiator).to eq "#{GlobalVariable::BASE_AUCTION}/#"
    end

    it 'should send invoice data to eeid' do
      invoice.initiator = 'eeid'
      invoice.save && invoice.reload

      expect(invoice.initiator).to eq 'eeid'

      invoice_sender = InvoiceDataSenderService.new(invoice: invoice)
      initiator = invoice_sender.send(:to_whom)

      expect(initiator).to eq "#{GlobalVariable::BASE_EEID}/#"
    end
  end

  describe 'response after send data' do
    let(:invoice) { create(:invoice) }

    it 'should return succesfully response' do
      response = {
        'message' => 'Invoice data updated successfully'
      }
      allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(response)

      response = InvoiceDataSenderService.call(invoice: invoice)

      expect(response.result?).to eq true
      expect(response.instance[:message]).to eq 'Invoice data updated successfully'
    end

    it 'shoudl return an error in response' do
      response = {
        'error' => {
          'message': 'Could not update the invoice'
        }
      }
      allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(response)

      response = InvoiceDataSenderService.call(invoice: invoice)

      expect(response.result?).to eq false
      expect(response.errors[:message]).to eq 'Could not update the invoice'
    end
  end
end
