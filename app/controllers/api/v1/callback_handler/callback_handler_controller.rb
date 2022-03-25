class Api::V1::CallbackHandler::CallbackHandlerController < Api::V1::CallbackHandler::BaseController
  KEY = 'c05fa8dae730cc0cf57fe445861953fa'
  LINKPAY_PREFIX = 'https://igw-demo.every-pay.com/lp'
  LINKPAY_TOKEN = 'k5t5xq'
  LINKPAY_QR = true
  API_USERNAME = 'ca8d6336dd750ddb'
  SUCCESSFUL_PAYMENT = %w[settled authorized].freeze

  def callback
    payment_reference = params[:payment_reference]

    url = generate_url(payment_reference: payment_reference, api_username: API_USERNAME)
    response = base_request(url: url, api_username: API_USERNAME, api_secret: KEY)
    parse_response(response)

    render json: { message: 'Thank you', status: :success }
  end

  private

  def identicate_payment_status(status)
    return :paid if SUCCESSFUL_PAYMENT.include? status

    :failed
  end

  def parse_response(response)
    parsed_response = response.symbolize_keys
    payment_status = identicate_payment_status(parsed_response[:payment_state])
    invoice = Invoice.find_by(invoice_number: parsed_response[:order_reference])

    return false if invoice.nil?

    invoice.update(payment_reference: parsed_response[:payment_reference],
                   status: payment_status,
                   transaction_time: parsed_response[:transaction_time],
                   everypay_response: parsed_response)

    parsed_response
  end

  def generate_url(payment_reference:, api_username:)
    "https://igw-demo.every-pay.com/api/v4/payments/#{payment_reference}?api_username=#{api_username}"
  end

  def base_request(url:, api_username:, api_secret:)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth api_username, api_secret

      response = http.request request

      return JSON.parse(response.body)
    end
  end
end
