class Api::V1::Directo::DirectoController < ApplicationController
  def create
    @invoice_data = params[:invoice_data]
    @initiator = params[:initiator]
    @invoice_number = params[:invoice_number]

    if call
      render json: { 'message' => 'Invoice data received', status: :created }
    else
      render json: { 'message' => 'Some error happen', status: :internal_server_error }
    end
  end

  private

  def save_information_to_invoice
    invoice = Invoice.find_by(invoice_number: @invoice_number)

    return true if invoice.update(directo_data: @invoice_data)

    false
  end

  def call
    DirectoInvoiceForwardJob.perform_now(invoice_data: @invoice_data, initiator: @initiator)
    save_information_to_invoice

    true
  end
end
