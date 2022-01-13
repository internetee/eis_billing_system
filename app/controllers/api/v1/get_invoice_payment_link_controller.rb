class Api::V1::GetInvoicePaymentLinkController < ApplicationController
  def show
    invoice = Invoice.find_by(invoice_number: params[:invoice_number])

    if invoice
      render json: { payment_link: invoice.payment_link, status: :created }
    else
      render json: { error: 'Invoice not found', status: :no_found }
    end
  end
end
