module Api
  module V1
    module CallbackHandler
      class CallbackHandlerController < ApplicationController
        skip_before_action :authorized

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
