class SendEInvoiceJob < ApplicationJob
  # discard_on HTTPClient::TimeoutError

  def perform(e_invoice_data)
    # byebug
    logger.info "Started to process e-invoice for invoice_id #{e_invoice_data[:invoice_data][:id]}"
    process(e_invoice_data)
  rescue StandardError => e
    log_error(invoice: e_invoice_data[:invoice_data][:id], error: e)
    raise e
  end

  private

  def process(e_invoice_data)
    e_invoice_instance = EInvoiceGenerator.new(e_invoice_data)
    e_invoice_instance.generate.deliver

    EInvoiceResponseSender.send_request(invoice_number: e_invoice_data[:invoice_data][:number])
    log_success(e_invoice_data)
  end

  def log_success(e_invoice_data)
    message = "E-Invoice for an invoice with ID # #{e_invoice_data[:invoice_data][:id]} was sent successfully"
    logger.info message
  end

  def log_error(invoice:, error:)
    message = <<~TEXT.squish
      There was an error sending e-invoice for invoice with ID # #{invoice}.
      The error message was the following: #{error}
      This job will retry.
    TEXT
    logger.error message
  end

  def logger
    Rails.logger
  end
end
