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
          - business_registry

          In this case, only the auction has the possibility of multiple payment
        HERE
        param :linkpay_token, String, required: true, desc: <<~HERE
          Token to be generated based on everypay client api and everypay client key
        HERE
        param :invoice_number, String, required: true

        def create
          Rails.logger.info(
            "[BILLING-GENERATE] start invoice_number=#{params[:invoice_number].inspect} " \
            "initiator=#{params[:custom_field2].inspect} amount=#{params[:transaction_amount].inspect} " \
            "request_id=#{request.request_id}"
          )

          invoice = InvoiceInstanceGenerator.create(params:)
          link = EverypayLinkGenerator.create(params:)

          Rails.logger.info(
            "[BILLING-GENERATE] saved id=#{invoice&.id} invoice_number=#{invoice&.invoice_number} " \
            "request_id=#{request.request_id}"
          )

          render json: { 'message' => 'Link created', 'everypay_link' => link }, status: :created
        rescue StandardError => e
          Rails.logger.error(
            "[BILLING-GENERATE] FAILED invoice_number=#{params[:invoice_number].inspect} " \
            "request_id=#{request.request_id} -> #{e.class}: #{e.message}"
          )
          Rails.logger.error(e.backtrace.join("\n")) if e.backtrace
        end
      end
    end
  end
end
