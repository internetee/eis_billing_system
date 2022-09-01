module Api
  module V1
    module CallbackHandler
      class CallbackHandlerController < ApplicationController
        def callback
          payment_reference = params[:payment_reference]
          response = EverypayResponse.send_request(payment_reference)
          notifier = Notify.new(response: response)
          result = notifier.call

          render status: :ok, json: { message: result }
        end
      end
    end
  end
end
