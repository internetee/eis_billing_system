class Api::V1::EInvoice::EInvoiceController < ApplicationController
  def create
    e_invoice_data = {
      invoice_data: invoice_params[:invoice],
      invoice_subtotal: invoice_params[:invoice_subtotal],
      vat_amount: invoice_params[:vat_amount],
      invoice_items: invoice_params[:items],
      payable: invoice_params.fetch(:payable, true),
      buyer_billing_email: invoice_params[:buyer_billing_email],
      buyer_e_invoice_iban: invoice_params[:buyer_e_invoice_iban],
      seller_country_code: invoice_params[:seller_country_code],
      buyer_country_code: invoice_params[:buyer_country_code],
      initiator: invoice_params[:initiator],
    }

    SendEInvoiceJob.perform_now(e_invoice_data)

    render json: { 'message' => 'Invoice data received', status: :created }
  end

  private

  def invoice_params
    params.to_unsafe_h
  end
end
