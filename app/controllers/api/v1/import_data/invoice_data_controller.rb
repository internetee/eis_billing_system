class Api::V1::ImportData::InvoiceDataController < ApplicationController
  def create
    response = params['_json']
    added_count = 0
    skipped_count = 0

    response.each do |data|
      invoice_number = data['invoice_number']
      initiator = data['initiator']
      transaction_amount = data['transaction_amount']

      if invoice_number.nil?
        skipped_count += 1

        next
      end

      unless Invoice.find_by(invoice_number: invoice_number).nil?
        skipped_count += 1

        next
      end

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

      added_count += 1
    end

    render status: :ok, json: { message: "Added #{added_count} invoices, skipped #{skipped_count}. The reason for omission may be that the account data is already in the database or the information is incorrect" }
  end

  private

  def log_request(invoice_number:, initiator:, transaction_amount:)
    Rails.logger.info invoice_number
    Rails.logger.info initiator
    Rails.logger.info transaction_amount
    Rails.logger.info "++++++++++++++++++"
  end
end
