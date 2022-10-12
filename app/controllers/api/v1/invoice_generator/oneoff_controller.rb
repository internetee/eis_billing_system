module Api
  module V1
    module InvoiceGenerator
      class OneoffController < Api::V1::InvoiceGenerator::BaseController
        def create
          response = Oneoff.call(invoice_number: params[:invoice_number],
                                 customer_url: params[:customer_url],
                                 reference_number: params[:reference_number])

          if response['error'].present?
            render json: { error: response['error'] }, status: :unprocessable_entity
          else
            render json: { 'message' => 'Link created',
                           'oneoff_redirect_link' => response['payment_link'] },
                   status: :created
          end
        rescue StandardError => e
          Rails.logger.info e
        end
      end
    end
  end
end
