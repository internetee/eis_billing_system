module Api
  module V1
    module InvoiceGenerator
      class InvoiceGeneratorController < ApplicationController
        api! 'Linkpay link generator for payment'

        param :transaction_amount, String, required: true, desc: <<~HERE
          The total amount to be paid
        HERE
        param :reference_number, String, required: false
        param :order_reference, String, required: true, desc: <<~HERE
          This is the description of the account. As a rule, the account number is indicated here
        HERE
        param :customer_name, String, required: true
        param :customer_email, String, required: true
        param :custom_field_1, String, required: true, desc: <<~HERE
          Invoice description
        HERE
        param :custom_field2, String, required: true, desc: <<~HERE
          Values contains the names of the service that initiates the request. These can be:
          - registry
          - eeid
          - auction

          In this case, only the auction has the possibility of multiple payment
        HERE
        param :linkpay_token, String, required: true, desc: <<~HERE
          Token to be generated based on everypay client api and everypay client key
        HERE
        param :invoice_number, String, required: true

        def create
          InvoiceInstanceGenerator.create(params: params)
          link = EverypayLinkGenerator.create(params: params)

          render json: { 'message' => 'Link created', 'everypay_link' => link }, status: :created
        rescue StandardError => e
          Rails.logger.info e
        end
      end
    end
  end
end
