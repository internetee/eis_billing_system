module Api
  module V1
    module Invoice
      class ReservedDomainsInvoiceStatusesController < ApplicationController
        before_action :set_invoice, only: :show

        def show
          if @invoice.paid?
            render json: {
                     message: 'Domain is reserved',
                     invoice_status: 'paid',
                     invoice_number: params[:invoice_number]
                   },
                   status: :ok
          else
            render json: {
                     message: 'Domains are not reserved',
                     invoice_status: 'unpaid',
                     invoice_number: params[:invoice_number]
                   },
                   status: :ok
          end
        end

        private

        def set_invoice
          user_unique_id = params[:user_unique_id]
          invoice_number = params[:invoice_number]
          description_pattern = "%User unique id: #{user_unique_id}%"
          @invoice = ::Invoice.where('invoice_number = ? AND description LIKE ?', invoice_number,
                                     description_pattern).first

          raise ActiveRecord::RecordNotFound, 'Invoice not found' if @invoice.nil?
        end
      end
    end
  end
end
