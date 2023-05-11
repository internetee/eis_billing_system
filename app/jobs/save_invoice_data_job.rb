class SaveInvoiceDataJob < ApplicationJob
  def perform(response)
    parse_response(response)
  end

  private

  def parse_response(response)
    added_count = 0
    skipped_count = 0
    data_collection = {}

    response.each do |data|
      data_collection = collect_response_data(data)

      if data_collection[:invoice_number].nil?
        skipped_count += 1

        next
      end

      unless Invoice.find_by(invoice_number: data_collection[:invoice_number]).nil?
        skipped_count += 1

        next
      end

      log_request(invoice_number: data_collection[:invoice_number],
                  initiator: data_collection[:initiator],
                  transaction_amount: data_collection[:transaction_amount])

      generate_invoice(attrs: data_collection)

      added_count += 1
    end

    [added_count, skipped_count]
  end

  def collect_response_data(data)
    status = data['status']
    status = 'unpaid' if status == 'issued'

    {
      invoice_number: data['invoice_number'],
      initiator: data['initiator'],
      transaction_amount: data['transaction_amount'],
      in_directo: data['in_directo'],
      e_invoice_sent_at: data['e_invoice_sent_at'],
      transaction_time: data['transaction_time'],
      status: status
    }
  end

  def generate_invoice(attrs:)
    invoice = Invoice.new
    invoice.invoice_number = attrs[:invoice_number]
    invoice.initiator = attrs[:initiator]
    invoice.transaction_amount = attrs[:transaction_amount]
    invoice.status = attrs[:status]
    invoice.in_directo = attrs[:in_directo]
    invoice.sent_at_omniva = attrs[:e_invoice_sent_at]
    invoice.transaction_time = attrs[:transaction_time]
    invoice.description = attrs.fetch(:description, 'prepended')

    invoice.save!
  end

  def log_request(invoice_number:, initiator:, transaction_amount:)
    Rails.logger.info invoice_number
    Rails.logger.info initiator
    Rails.logger.info transaction_amount
    Rails.logger.info "++++++++++++++++++"
  end
end
