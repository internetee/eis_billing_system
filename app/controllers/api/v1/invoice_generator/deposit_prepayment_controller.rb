module Api
  module V1
    module InvoiceGenerator
      class DepositPrepaymentController < Api::V1::InvoiceGenerator::BaseController
        def create
          response = DepositPrepaymentService.call(params: params)

          if response.result?
            render json: { 'message' => 'Link created',
                           'oneoff_redirect_link' => response.instance['payment_link'] },
                   status: :created
          else
            render json: { error: response.instance['error'] }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
