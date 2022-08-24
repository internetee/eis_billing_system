class EverypayController < ParentController
  before_action :require_user_logged_in!

  def index; end

  def everypay_data
    payment_reference = params[:payment_reference]

    response = EverypayResponse.send_request(payment_reference)
    notifier = Notify.new(response: response)
    result = notifier.call

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('response_everypay',
                                html: "<h2 class='mt-3'>Everypay response result</h2><div class='bg-gray-300 p-4 mt-1 mb-3'><code>#{response}</code></div>".html_safe),
          turbo_stream.replace('notifier_result',
                                html: "<h2 class='mt-3'>Payment result</h2><div class='bg-gray-300 p-4 mt-1 mb-3'><code>#{result.code}</code><div>#{result.body}</div></div>".html_safe),
        ]
      end
    end
  end
end
