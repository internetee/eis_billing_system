module Api
  module V1
    module InvoiceGenerator
      class DepositPrepaymentController < ApplicationController
        DESCRIPTION_DEFAULT = 'deposit'.freeze

        def create
          invoice_number = InvoiceNumberService.call
          invoice_params = {
            invoice_number: invoice_number,
            initiator: params[:custom_field2].to_s,
            transaction_amount: params[:transaction_amount].to_s,
            description: params.fetch(:custom_field1, DESCRIPTION_DEFAULT).to_s
          }

          InvoiceInstanceGenerator.create(params: invoice_params)
          response = Oneoff.send_request(invoice_number: invoice_number,
                                         customer_url: params[:customer_url],
                                         reference_number: params[:reference_number])

          render json: { 'message' => 'Link created',
                         'oneoff_redirect_link' => response['payment_link'] },
                 status: :created
        end
      end
    end
  end
end
