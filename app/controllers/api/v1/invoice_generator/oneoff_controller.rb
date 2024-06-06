module Api
  module V1
    module InvoiceGenerator
      class OneoffController < Api::V1::InvoiceGenerator::BaseController
        api! 'Generating a link to pay a bill through the OneOff endpoint'

        param :invoice_number, String, required: true
        param :customer_url, String, required: true, desc: <<~HERE
          The link where the user must be redirected after payment. Along with the transition also on this link comes the data about the payment. This is a kind of redirect_url and callback_url
        HERE
        param :reference_number, String, required: false
        param :amount, String, required: false

        def create
          response = Oneoff.call(invoice_number: params[:invoice_number],
                                 customer_url: params[:customer_url],
                                 reference_number: params[:reference_number],
                                 amount: params[:amount])
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
