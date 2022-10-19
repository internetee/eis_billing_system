module Api
  module V1
    module InvoiceGenerator
      class BulkPaymentController < Api::V1::InvoiceGenerator::BaseController
        def create
          response = Auction::BulkPaymentService.call(params: params.to_unsafe_hash)
          if response.result?
            render json: { 'message' => 'Link created',
                           'oneoff_redirect_link' => response.instance['payment_link'] },
                   status: :created
          else
            render json: { error: response.errors }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
