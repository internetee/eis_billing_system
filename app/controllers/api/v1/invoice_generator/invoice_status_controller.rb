class Api::V1::InvoiceGenerator::InvoiceStatusController < Api::V1::InvoiceGenerator::BaseController
  def show
    invoice = Invoice.find_by(invoice_number: params[:id])

    if invoice.status == :unpaid
      render json: { 'message' => 'Invoice found', 'status' => invoice.status }
    else
      render json: { 'message' => 'Invoice found',
                     'status' => invoice.status,
                     'transaction_time' => invoice.transaction_time,
                     'everypay_response' => invoice.everypay_response }
    end
  rescue StandardError => e
    logger.info e
  end
end
