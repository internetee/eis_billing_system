module Api
  module V1
    module CallbackHandler
      class MontonioController < ApplicationController
        # Montonio cannot send our Bearer JWT. The request is authenticated by
        # the signature of the token in the body instead.
        skip_before_action :authorized

        api! 'Receives payment notifications from Montonio payment links'

        param :orderToken, String, required: false, desc: <<~HERE
          JWT signed with our Montonio secret key. Contains, among others, **paymentLinkUuid**
          (identifies our invoice), **uuid** (Montonio order id), **paymentStatus**
          (PENDING, PAID, VOIDED, PARTIALLY_REFUNDED, REFUNDED, ABANDONED, AUTHORIZED),
          **grandTotal** and **currency**. Only **PAID** marks the invoice as paid.
        HERE
        param :refundToken, String, required: false, desc: <<~HERE
          JWT signed with our Montonio secret key, sent when a payment is refunded.
          It is logged only, the invoice is not changed.
        HERE

        def create
          return handle_refund if params[:refundToken].present?

          result = Montonio::PaymentProcessor.call(order_token: params[:orderToken])

          render status: :ok, json: { message: result.message,
                                      state: result.state,
                                      invoice_number: result.invoice&.invoice_number }
        rescue Montonio::InvalidTokenError => e
          Rails.logger.error("Montonio webhook rejected: #{e.message}")
          render status: :unauthorized, json: { message: e.message }
        rescue Montonio::UnknownPaymentLinkError => e
          Rails.logger.error("Montonio webhook rejected: #{e.message}")
          render status: :not_found, json: { message: e.message }
        rescue Montonio::Error => e
          Rails.logger.error("Montonio webhook could not be handled: #{e.message}")
          render status: :unprocessable_entity, json: { message: e.message }
        end

        private

        # Refunds change nothing on our side, but answering with an error would
        # make Montonio retry the delivery for 48 hours.
        def handle_refund
          payload = Montonio::OrderTokenVerifier.call(params[:refundToken])
          Rails.logger.info("Montonio refund notification received: #{payload}")

          render status: :ok, json: { message: 'Refund notification received', state: 'refund_logged' }
        rescue Montonio::Error => e
          Rails.logger.error("Montonio refund notification could not be verified: #{e.message}")

          render status: :ok, json: { message: 'Refund notification could not be verified', state: 'refund_logged' }
        end
      end
    end
  end
end
