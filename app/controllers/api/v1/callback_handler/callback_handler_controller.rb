class Api::V1::CallbackHandler::CallbackHandlerController < Api::V1::CallbackHandler::BaseController
  def callback
    payment_reference = params[:payment_reference]
    response = EverypayResponse.send_request(payment_reference)

    notifier = Notify.new(response: response)
    result = notifier.call

    render status: :ok, json: { message: result }
  end
end
