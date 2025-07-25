require 'rails_helper'
require 'httpi'   # HTTPI::Response
require 'nori'    # Nori для парсинга SOAP

RSpec.describe "SendEInvoiceJob", type: :job do
  let!(:admin) { create(:user) }

  before(:each) do
    ActiveJob::Base.queue_adapter = :test
    ActionMailer::Base.delivery_method = :test

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

      expect { SendEInvoiceJob.perform_now(params) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'retries the job when Savon::SOAPFault is raised' do
      params = {
        invoice_data: {
          id: '2',
          number: invoice.invoice_number,
        }
      }

      fault_xml = <<~XML
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <soap:Fault>
              <faultcode>Server</faultcode>
              <faultstring>Something went wrong</faultstring>
            </soap:Fault>
          </soap:Body>
        </soap:Envelope>
      XML

      real_response = HTTPI::Response.new(500, {}, fault_xml)
      soap_fault    = Savon::SOAPFault.new(real_response, Nori.new)

      allow_any_instance_of(SendEInvoiceJob)
        .to receive(:process)
        .and_raise(soap_fault)

      job = SendEInvoiceJob.new

      expect(job)
        .to receive(:retry_job)
        .with(wait: 1.minute, attempts: 3)

      # просто запускаем – никаких SOAPFault наружу не уходит
      expect { job.perform(params) }.not_to raise_error
    end

  end
end
