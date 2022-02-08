class Api::V1::Directo::DirectoController < ApplicationController
  def create
    invoice_data = params[:invoice_data]
    dry = params[:dry]
    monthly = params[:monthly]
    initiator = params[:initiator]

    DirectoInvoiceForwardJob.perform_now(invoice_data: invoice_data, initiator: initiator, monthly: monthly, dry: dry)

    render json: { 'message' => 'Invoice data received', status: :created }
  end
end