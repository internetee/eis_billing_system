module Api
  module V1
    module Invoice
      class InvoiceSynchronizesController < ApplicationController
        def update
          invoice = ::Invoice.find(params[:id])
          response = invoice.synchronize

          if response.result?
            render json: {
              message: 'Invoice data was successfully updated'
            }, status: :ok
          else
            render json: {
              error: response.errors.with_indifferent_access[:message]
            }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
