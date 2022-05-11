require 'rails_helper'

RSpec.describe "SendEInvoiceJob", type: :job do
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.delivery_method = :test

    uri_object = OpenStruct.new
    uri_object.host = 'http://endpoint/get'
    uri_object.port = '3000'

    allow(URI).to receive(:parse).and_return(uri_object)
    allow_any_instance_of(EInvoiceResponseSender).to receive(:get_endpoint_services_e_invoice_url).and_return('http://endpoint/get')
    allow(EInvoiceResponseSender).to receive(:generate_headers).and_return({'header': 'header'})
    allow_any_instance_of(Net::HTTP).to receive(:put).and_return('200 - ok')
  end

  describe 'EInvoice deliver' do
    let(:invoice) { create(:invoice) }

    it 'invoice data should be delivered to Omniva' do
      response = {
        e_invoice_response: {
          message: 'Success delivered'
        }
      }

      params = {
        invoice_data: {
          id: '2',
          number: invoice.invoice_number
        }
      }

      e_invoice_instance = OpenStruct.new
      e_invoice_instance.deliver = response

      expect_any_instance_of(EInvoiceGenerator).to receive(:generate).and_return(e_invoice_instance)

      SendEInvoiceJob.perform_now(params)
      invoice.reload
      expect(invoice.sent_at_omniva.to_date).to match(Time.zone.now.to_date)
    end
  end

  describe 'Failed handler' do
    let(:invoice) { create(:invoice) }

    it 'should send notify thath omniva delivering was failed' do
      response_failed = {
        e_invoice_response: {
          message: 'Failed delivered'
        }
      }

      params = {
        invoice_data: {
          id: '2',
          number: invoice.invoice_number
        }
      }

      e_invoice_instance = OpenStruct.new
      e_invoice_instance.deliver = response_failed

      expect_any_instance_of(EInvoiceGenerator).to receive(:generate).and_return(e_invoice_instance)

      expect { SendEInvoiceJob.perform_now(params) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
