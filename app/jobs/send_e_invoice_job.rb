class SendEInvoiceJob < ApplicationJob
  # discard_on HTTPClient::TimeoutError

  def perform(e_invoice_data)
    Rails.logger.info "Started to process e-invoice for invoice_id #{e_invoice_data[:invoice_data][:id]}"
    process(e_invoice_data)
  rescue StandardError => e
    log_error(invoice: e_invoice_data[:invoice_data][:id], error: e)
    raise e
  end

  private

  def process(e_invoice_data)
    invoice_number = e_invoice_data[:invoice_data][:number]

    e_invoice_instance = EInvoiceGenerator.new(e_invoice_data)
    data = e_invoice_instance.generate.deliver
    message = data.to_hash[:e_invoice_response][:message]

    if message.include? 'Success'
      EInvoiceResponseSender.send_request(invoice_number: e_invoice_data[:invoice_data][:number])
      invoice = Invoice.find_by(invoice_number: invoice_number)
      invoice.update(sent_at_omniva: Time.zone.now)
    else
      Rails.logger.info 'FAILED IN EINVOICE OMNIVA TRANSFER'
      NotifierMailer.inform_admin(title: 'Failed e-invoice delivering', error_message: message).deliver_now
    end
  end

  def log_success(e_invoice_data)
    message = "E-Invoice for an invoice with ID # #{e_invoice_data[:invoice_data][:id]} was sent successfully"
    Rails.logger.info message
  end

  def log_error(invoice:, error:)
    message = <<~TEXT.squish
      There was an error sending e-invoice for invoice with ID # #{invoice}.
      The error message was the following: #{error}
      This job will retry.
    TEXT
    Rails.logger.error message
    NotifierMailer.inform_admin(title: 'Failed e-invoice delivering', error_message: message).deliver_now
  end
end
