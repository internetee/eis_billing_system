module Api
  module V1
    module InvoiceGenerator
      class OneoffController < Api::V1::InvoiceGenerator::BaseController
        def create
          response = Oneoff.call(invoice_number: params[:invoice_number],
                                 customer_url: params[:customer_url],
                                 reference_number: params[:reference_number])
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
