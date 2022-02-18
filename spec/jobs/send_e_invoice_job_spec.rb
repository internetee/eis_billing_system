require 'rails_helper'

RSpec.describe "SendEInvoiceJob", type: :job do
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  params = {
    invoice_data: {
      id: '2',
      number: '23'
    },
    initiator: 'registry'
  }

  describe '' do
    it '' do
      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint/get'
      uri_object.port = '3000'

      allow(URI).to receive(:parse).and_return(uri_object)
      allow(EInvoiceResponseSender).to receive(:invoice_generator_url).and_return('http://endpoint/get')
      allow(EInvoiceResponseSender).to receive(:headers).and_return({'header': 'header'})
      expect_any_instance_of(Net::HTTP).to receive(:put).and_return('200 - ok')

      class Generator
        def deliver
          true
        end
      end

      e_invoice_instance = OpenStruct.new
      generator = Generator.new
      e_invoice_instance.generate = generator

      expect_any_instance_of(EInvoiceGenerator).to receive(:generate).and_return(e_invoice_instance)

      SendEInvoiceJob.perform_now(params)
    end
  end
end
