class Api::V1::ImportData::InvoiceDataController < ApplicationController
  def create
    response = params['_json']
    response.each do |data|
      invoice_number = data['invoice_number']
      initiator = data['initiator']
      transaction_amount = data['transaction_amount']

      next if invoice_number.nil?

      next unless Invoice.find_by(invoice_number: invoice_number).nil?

      log_request(invoice_number: invoice_number, initiator: initiator, transaction_amount: transaction_amount)

      status = data['status']
      status = 'unpaid' if status == 'issued'

      invoice = Invoice.new
      invoice.invoice_number = invoice_number
      invoice.initiator = initiator
      invoice.transaction_amount = transaction_amount
      invoice.status = status
      invoice.in_directo = data['in_directo']
      invoice.sent_at_omniva = data['e_invoice_sent_at']
      invoice.transaction_time = data['transaction_time']

      invoice.save!
    end

    render status: :ok
  end

  private

  def log_request(invoice_number:, initiator:, transaction_amount:)
    Rails.logger.info invoice_number
    Rails.logger.info initiator
    Rails.logger.info transaction_amount
    Rails.logger.info "++++++++++++++++++"
  end
end
