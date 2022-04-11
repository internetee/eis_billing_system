class Api::V1::ImportData::InvoiceDataController < ApplicationController
  def create
    response = params["_json"]
    response.each do |data|
      invoice_number = data["invoice_number"]
      initiator = data["initiator"]
      transaction_amount = data["transaction_amount"]

      next unless Invoice.find_by(invoice_number: invoice_number).nil?

      log_request(invoice_number: invoice_number, initiator: initiator, transaction_amount: transaction_amount)

      invoice = Invoice.new
      invoice.invoice_number = data['invoice_number']
      invoice.initiator = data['initiator']
      invoice.transaction_amount = data['transaction_amount']
      invoice.status = data['status']
      invoice.in_directo = data['in_directo']
      invoice.sent_at_omniva = data['e_invoice_sent_at']
      invoice.transaction_time = data['transaction_time']

      invoice.save!
    end

    render status: 200, json: { status: 'ok' }
  end

  private

  def log_request(invoice_number:, initiator:, transaction_amount:)
    logger.info invoice_number
    logger.info initiator
    logger.info transaction_amount
    logger.info "++++++++++++++++++"
  end
end
