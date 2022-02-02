class Api::V1::EInvoice::EInvoiceController < ApplicationController
  def create
    e_invoice_data = {
      invoice_data: params[:invoice],
      invoice_subtotal: params[:invoice_subtotal],
      vat_amount: params[:vat_amount],
      invoice_items: params[:items],
      payable: params.fetch(:payable, true),
      buyer_billing_email: params[:buyer_billing_email],
      buyer_e_invoice_iban: params[:buyer_e_invoice_iban],
      seller_country: params[:seller_country],
      buyer_country: params[:buyer_country]
    }

    SendEInvoiceJob.perform_now(e_invoice_data)

    render json: { 'message' => 'Invoice data received', status: :created }
  end
end
