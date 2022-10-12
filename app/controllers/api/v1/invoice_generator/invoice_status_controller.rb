module Api
  module V1
    module InvoiceGenerator
      class InvoiceStatusController < Api::V1::InvoiceGenerator::BaseController
        def create
          invoice = Invoice.find_by(invoice_number: params[:invoice_number])
          if invoice.nil?
            return notify(title: "Invoice with #{params[:invoice_number]} number not found",
                          error_message: "Invoice with #{params[:invoice_number]} number not found")
          end

          if invoice.update(status: params[:status])
            render json: { 'message' => 'Status updated' }, status: :ok
          else
            render json: { 'message' => 'Something goes wrong' }
            error_message = "Status for #{params[:invoice_number]} wasn't updated; Invoice #{invoice}"
            NotifierMailer.inform_admin(title: 'Status received error',
                                        error_message: error_message).deliver_now
          end
        rescue StandardError => e
          Rails.logger.info e
          NotifierMailer.inform_admin(title: 'Status received standard error',
                                      error_message: e).deliver_now
        end
      end
    end
  end
end
