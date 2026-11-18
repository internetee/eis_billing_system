require 'rails_helper'
require 'httpi'   # HTTPI::Response
require 'nori'    # Nori для парсинга SOAP

RSpec.describe "SendEInvoiceJob", type: :job do
  let!(:admin) { create(:user) }

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.delivery_method = :test
    # Counted at the mailer rather than in ActionMailer::Base.deliveries: ApplicationMailer's
    # `from` comes from ENV['action_mailer_default_from'], unset in tests, and a mail without a
    # sender is dropped silently there -- so deliveries never counted anything.
    allow(NotifierMailer).to receive(:inform_admin).and_call_original

    sucess_message = {
      message: 'Success delivered',
    }

    stub_request(:put, "#{GlobalVariable::BASE_REGISTRY}/eis_billing/e_invoice_response")
      .to_return(status: 200, body: sucess_message.to_json, headers: {})
  end

  describe 'EInvoice deliver' do
    let(:invoice) { create(:invoice) }

    it 'invoice data should be delivered to Omniva' do
      response = {
        e_invoice_response: {
          message: 'Success delivered',
        },
      }

      params = {
        invoice_data: {
          id: '2',
          number: invoice.invoice_number,
        },
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
          message: 'Failed delivered',
        },
      }

      params = {
        invoice_data: {
          id: '2',
          number: invoice.invoice_number,
        },
      }

      e_invoice_instance = OpenStruct.new
      e_invoice_instance.deliver = response_failed

      expect_any_instance_of(EInvoiceGenerator).to receive(:generate).and_return(e_invoice_instance)

      SendEInvoiceJob.perform_now(params)

      expect(NotifierMailer).to have_received(:inform_admin).once
    end

    def soap_fault(message)
      fault_xml = <<~XML
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <soap:Fault>
              <faultcode>Server</faultcode>
              <faultstring>#{message}</faultstring>
            </soap:Fault>
          </soap:Body>
        </soap:Envelope>
      XML

      Savon::SOAPFault.new(HTTPI::Response.new(500, {}, fault_xml), Nori.new)
    end

    let(:params) { { invoice_data: { id: '2', number: invoice.invoice_number } } }

    it 'retries a transient SOAP fault a minute later, without mailing the admins' do
      allow_any_instance_of(SendEInvoiceJob).to receive(:process).and_raise(soap_fault('Something went wrong'))

      expect { SendEInvoiceJob.perform_now(params) }.to have_enqueued_job(SendEInvoiceJob)
      expect(NotifierMailer).not_to have_received(:inform_admin)
    end

    it 'gives up after the last attempt and mails the admins once' do
      allow_any_instance_of(SendEInvoiceJob).to receive(:process).and_raise(soap_fault('Something went wrong'))
      job = SendEInvoiceJob.new(params)
      job.executions = SendEInvoiceJob::MAX_SOAP_ATTEMPTS - 1

      job.perform_now

      expect(NotifierMailer).to have_received(:inform_admin).once
      expect(SendEInvoiceJob).not_to have_been_enqueued
    end

    # Retrying a document Omniva rejected as malformed only repeats the rejection.
    it 'does not retry a fault about the document itself' do
      fault = soap_fault("(ns0:80) Unknown error has occurred. Illegal document structure. cvc-datatype-valid.1.1 - " \
                         "string value 'EE522200221094796536 ' does not match pattern for AccountType")
      allow_any_instance_of(SendEInvoiceJob).to receive(:process).and_raise(fault)

      SendEInvoiceJob.perform_now(params)

      expect(NotifierMailer).to have_received(:inform_admin).with(anything, /Giving up/).once
      expect(SendEInvoiceJob).not_to have_been_enqueued
    end
  end
end
