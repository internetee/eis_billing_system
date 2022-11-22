module Api
  module V1
    module CallbackHandler
      class CallbackHandlerController < ApplicationController
        skip_before_action :authorized

        api! 'Receives data from Everypay, when the payment was made by the customer'

        event_descr = <<~HERE
          **event_name** is sent for payment status, fraud and dispute updates as well as network token updates.\n\n
          Possible values for event_names:\n
          - **status_updated** - payment status is updated. To check the status of that payment, please use GET /payments/:payment_reference\n
          - **voided** - payment is voided, cancellation of authorization.\n
          - **refunded** - payment is refunded, reimbursement of payment.\n
          - **refund_failed** - open banking payment refund fails. In this case payment status might change, please use GET /payments/:payment_reference to - check the final status of that payment.\n
          - **chargebacked** - payment is charged backed, the cardholder has disputed payment and the issuer bank has initiated a chargeback process.\n
          - **marked_for_capture** - payment is marked for capture.\n
          - **abandoned** - payment is abandoned, final status and means that payment is failed.\n
          - **issuer_reported_fraudulent** - Payment has been marked as fraudulent payment and reported by the issuer.\n
          - **merchant_reported_fraudulent** - Payment has been marked as fraudulent payment and reported by merchant.\n
          - **dispute_opened** - Dispute is opened.\n
          - **dispute_updated** - Dispute is updated.\n
          - **dispute_reversed** - Dispute is reversed\n
          - **dispute_charged_back** - Dispute is charged back.\n
          - **dispute_reopened** - Dispute is reopened.\n\n
          Possible values for network token updates:\n
          - **card_art_updated** - Card art is received. Merchants can get the card art after this notification.\n
          - **token_updated** - Token status is updated by the issuer. Merchants can check the status of the token after getting this notification.\n
          - **status_update** - When payment acquiring is completed and funds received to the merchant's account. Available only if the acquiring bank - supports this functionality.\n
        HERE

        param :payment_reference, String, desc: <<~HERE
          **payment_reference** contains a hash with which you need to make a request to Everypay for additional information about the invoice'
        HERE
        param :event_name, String, desc: event_descr

        def callback
          payment_reference = params[:payment_reference]
          response = EverypayResponse.call(payment_reference)
          result = Notify.call(response: response)

          render status: :ok, json: { message: result }
        end
      end
    end
  end
end
