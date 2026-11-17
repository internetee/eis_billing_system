class SendEInvoiceJob < ApplicationJob
  # A SOAP fault is retried this many times in all, a minute apart, and then given up on.
  MAX_SOAP_ATTEMPTS = 3

  # Faults Omniva raises for the document itself: schema validation of what we sent. The same
  # data fails the same way every time, so retrying only repeats the failure (and its email).
  # The payload is fixed when the job is enqueued, so correcting the invoice at the initiator
  # does not reach a job already retrying -- it has to be sent again from there.
  PERMANENT_FAULT_MARKERS = ['Illegal document structure', 'cvc-'].freeze

  retry_on Net::ReadTimeout, wait: 2.seconds, attempts: 3

  def perform(e_invoice_data)
    Rails.logger.info "Started to process e-invoice for invoice_id #{e_invoice_data[:invoice_data][:id]}"
    process(e_invoice_data)
  rescue Savon::SOAPFault => e
    handle_soap_fault(invoice: e_invoice_data[:invoice_data][:id], error: e)
  rescue StandardError => e
    log_error(invoice: e_invoice_data[:invoice_data][:id], error: e, retrying: true)
    raise e
  end

  private

  def process(e_invoice_data)
    invoice_number = e_invoice_data[:invoice_data][:number]

    e_invoice_instance = EInvoiceGenerator.new(e_invoice_data)
    data = e_invoice_instance.generate.deliver
    message = data.to_hash[:e_invoice_response][:message]

    if message.include? 'Success'
      EInvoiceResponseSender.send_request(invoice_number:,
                                          initiator: e_invoice_data[:initiator])
      invoice = Invoice.find_by(invoice_number:)
      invoice&.update(sent_at_omniva: Time.zone.now)
    else
      Rails.logger.info 'FAILED IN EINVOICE OMNIVA TRANSFER'
      NotifierMailer.inform_admin('Failed e-invoice delivering', message).deliver_now
    end
  end

  # `retry_job` has no attempt limit of its own -- it used to be called with `attempts: 3`,
  # which it ignores, so a fault that never went away re-ran the job every minute for good.
  # `executions` counts the runs, this one included.
  def handle_soap_fault(invoice:, error:)
    if permanent_fault?(error) || executions >= MAX_SOAP_ATTEMPTS
      log_error(invoice:, error:, retrying: false)
    else
      Rails.logger.warn "E-invoice for invoice with ID # #{invoice} failed " \
                        "(attempt #{executions} of #{MAX_SOAP_ATTEMPTS}), retrying: #{error}"
      retry_job wait: 1.minute
    end
  end

  def permanent_fault?(error)
    PERMANENT_FAULT_MARKERS.any? { |marker| error.to_s.include?(marker) }
  end

  def log_success(e_invoice_data)
    message = "E-Invoice for an invoice with ID # #{e_invoice_data[:invoice_data][:id]} was sent successfully"
    Rails.logger.info message
  end

  def log_error(invoice:, error:, retrying:)
    outcome = retrying ? 'This job will retry.' : 'Giving up: correct the invoice data and send the e-invoice again.'
    message = <<~TEXT.squish
      There was an error sending e-invoice for invoice with ID # #{invoice}.
      The error message was the following: #{error}
      #{outcome}
    TEXT
    Rails.logger.error message
    NotifierMailer.inform_admin('Failed e-invoice delivering', message).deliver_now
  end
end
