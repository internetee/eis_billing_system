class Api::V1::InvoiceGenerator::InvoiceStatusController < Api::V1::InvoiceGenerator::BaseController
  def create
    # link = InvoiceGenerator.run(params)

    invoice = Invoice.find_by(invoice_number: params[:invoice_number])
    invoice.update(status: params[:status])

    render json: { 'message' => 'Link created', 'params' => params, status: :created }
  rescue StandardError => e
    Rails.logger.info e
  end
end
