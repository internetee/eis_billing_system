module Api
  module V1
    module Refund
      class AuctionController < ApplicationController
        before_action :load_invoice

        def create
          response = RefundService.call(amount: @invoice.transaction_amount,
                                        payment_reference: @invoice.payment_reference)

          if response.result?
            @invoice.update(status: 'refunded')

            render json: {
              message: 'Invoice was refunded'
            }, status: :ok
          else
            render json: {
              error: response.errors
            }, status: :unprocessable_entity
          end
        end

        private

        def load_invoice
          @invoice = ::Invoice.find_by(invoice_number: params[:params][:invoice_number])
          return if @invoice.present?

          render json: {
            error: 'Invoice not found'
          }, status: :not_found
        end
      end
    end
  end
end
