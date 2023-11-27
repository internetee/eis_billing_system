class EverypayController < ParentController
  def index; end

  def everypay_data
    response = EverypayResponse.call(params[:payment_reference])
    Notify.call(response:)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('response_everypay',
                               html: html_response(response).html_safe)
        ]
      end
    end
  end

  def html_response(response)
    "<h2 class='mt-3'>Everypay response result</h2><div class='bg-gray-300 p-4 mt-1 mb-3'>
     <code>#{response}</code></div>"
  end
end
