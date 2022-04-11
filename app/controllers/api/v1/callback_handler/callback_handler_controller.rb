class Api::V1::CallbackHandler::CallbackHandlerController < Api::V1::CallbackHandler::BaseController
  def callback
    payment_reference = params[:payment_reference]
    response = EverypayResponse.send_request(payment_reference)
    result = Notify.call(response)

    render json: { message: result, status: :success }
  end
end
