module Api
  module V1
    module Invoice
      class UpdateInvoiceDataController < ApplicationController
        def update
          invoice = ::Invoice.find_by(invoice_number: params[:invoice_number])
          transaction_amount = params[:transaction_amount]

          if invoice.update(transaction_amount:)
            render json: { message: 'Invoice data was successfully updated' }, status: :ok
          else
            render json: { error: invoice.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
