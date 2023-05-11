module Api
  module V1
    module InvoiceGenerator
      class InvoiceStatusController < Api::V1::InvoiceGenerator::BaseController
        api! 'Invoice status updates'

        param :invoice_number, String, required: true
        param :status, String, required: true

        def create
          invoice = ::Invoice.find_by(invoice_number: params[:invoice_number])

          if invoice.nil?
            message = "Invoice with #{params[:invoice_number]} number not found in Invoice Status Controller"
            NotifierMailer.inform_admin("Invoice with #{params[:invoice_number]} number not found",
                                         message).deliver_now
            raise ActiveRecord::RecordNotFound, "Invoice with #{params[:invoice_number]} number not found"
          end

          if invoice.update(status: params[:status])
            render json: { 'message' => 'Status updated' }, status: :ok
          else
            error_message = "Status for #{params[:invoice_number]} wasn't updated; Invoice #{invoice}"
            NotifierMailer.inform_admin('Status received error', error_message).deliver_now
            render json: { 'message' => error_message }
          end
        rescue StandardError => e
          Rails.logger.info e
          NotifierMailer.inform_admin('Status received standard error', e).deliver_now
        end
      end
    end
  end
end
