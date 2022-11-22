class Api::V1::EInvoice::EInvoiceController < ApplicationController
  api! 'Send existing invoice to Omniva EInvoice'

  param :invoice, String, required: true, desc: <<~HERE
    Contains the data of the invoice that will be sent to Omniva EInvoice
  HERE
  param :invoice_subtotal, String, required: true, desc: <<~HERE
    Contains information about the subtotal of an invoice to be sent
  HERE
  param :vat_amount, String, required: true, desc: <<~HERE
    Tax figure in percent
  HERE
  param :invoice_items, String, required: true, desc: <<~HERE
    Invoice details, those items that form the total bill
  HERE
  param :payable, [true, false], required: true, desc: <<~HERE
    By default it true
  HERE
  param :buyer_billing_email, String, required: true
  param :buyer_e_invoice_iban, String, required: true
  param :seller_country_code, String, required: true
  param :buyer_country_code, String, required: true
  param :initiator, String, desc: <<~HERE
    Values contains the names of the service that initiates the request. These can be:
    - registry
    - eeid
    - auction
  HERE

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
