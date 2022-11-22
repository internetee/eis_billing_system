module Api
  module V1
    module InvoiceGenerator
      class BulkPaymentController < Api::V1::InvoiceGenerator::BaseController
        api! 'Multiple payment methods'

        param :custom_field2, String, required: true, desc: <<~HERE
          Values contains the names of the service that initiates the request. These can be:
          - registry
          - eeid
          - auction

          In this case, only the auction has the possibility of multiple payment
        HERE
        param :customer_url, String, required: true, desc: <<~HERE
          The link where the user must be redirected after payment. Along with the transition also on this link comes the data about the payment. This is a kind of redirect_url and callback_url
        HERE
        param :description, String, required: true, desc: <<~HERE
          Payment Description. WARNING: This description is stored in the database of the billing system, it is not stored in the description of payments on the Everypay side
        HERE
        param :transaction_amount, String, required: true, desc: <<~HERE
          The total amount to be paid
        HERE

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
