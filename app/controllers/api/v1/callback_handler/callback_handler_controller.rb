class Api::V1::CallbackHandler::CallbackHandlerController < Api::V1::CallbackHandler::BaseController
  KEY = 'c05fa8dae730cc0cf57fe445861953fa'
  LINKPAY_PREFIX = 'https://igw-demo.every-pay.com/lp'
  LINKPAY_TOKEN = 'k5t5xq'
  LINKPAY_QR = true
  API_USERNAME = 'ca8d6336dd750ddb'

  def callback
    # https://support.every-pay.com/merchant-support/integrate-linkpay-callbacks/
    # /api/v1/callback_handler/callback
    # https://igw-demo.every-pay.com/api/v3/payments/payment_reference?api_username=7a40xxxb9b13d

    payment_reference = params[:payment_reference]
    # order_reference = params[:order_reference]

    url = generate_url(payment_reference: payment_reference, api_username: API_USERNAME)
    response = base_request(url: url, api_username: API_USERNAME, api_secret: KEY)

    ParseResponse.call(response)

    render json: {'message' => 'Callback comes', status: :ok}
  end

  private

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

# "{\"account_name\":\"EUR3D1\",\"order_reference\":\"88966\",\"email\":\"oleg.hasjanov@internet.ee\",\"customer_ip\":\"85.253.148.143\",\"customer_url\":null,\"payment_created_at\":\"2021-12-03T11:28:49.655Z\",\"initial_amount\":10.0,\"standing_amount\":10.0,\"payment_reference\":\"181a568bcba942180a68e5687eb56563569ad06e9abd8e5f288b60bf5c226690\",\"payment_link\":\"https://igw-demo.every-pay.com/lp/k5t5xq/t67hUZPm\",\"api_username\":\"ca8d6336dd750ddb\",\"warnings\":{\"too_many_different_cc_numbers\":[\"Too many different card numbers has been used with the same IP address (85.253.148.143)!\"],\"transaction_attempts_email_usage_frequency_in_hours\":[\"Email (oleg.hasjanov@internet.ee) has been used in transaction attempts more than maximum allowed: '3'.\"],\"transaction_attempts_ip_usage_frequency_in_hours\":[\"IP address (85.253.148.143) has been used in transaction attempts more than maximum allowed\"],\"transaction_attempts_email_usage_frequency\":[\"Email (oleg.hasjanov@internet.ee) has been used in transaction attempts more than maximum allowed: '5'.\"],\"transaction_attempts_ip_usage_frequency\":[\"IP address (85.253.148.143) has been used in transaction attempts more than maximum allowed\"]},\"stan\":665816,\"fraud_score\":1400,\"payment_state\":\"settled\",\"payment_method\":\"lhv_ob_ee\",\"ob_details\":{\"debtor_iban\":\"EE277700771001735881\",\"creditor_iban\":\"EE168938346545967075\",\"ob_payment_reference\":\"87124e79-655c-4500-9c5d-346b16e04d72\",\"ob_payment_state\":\"ACSC\"},\"transaction_time\":\"2021-12-03T11:28:50.097Z\"}

# Started GET "/api/v1/callback_handler/callback_handler/callback?payment_reference=06d1175c2b6b26e23dcde3cfe0d0ed473d1e3973a22c4cb1801a44ae45ba7a2e&order_reference=47223"
#
#
# Processing by Api::V1::CallbackHandler::CallbackHandlerController#callback as JSON
# Parameters: {"nonce"=>"2e2b52df645065fb0785091fc356a6bc", "timestamp"=>"1638448650", "api_username"=>"ca8d6336dd750ddb", "transaction_result"=>"failed", "processing_errors"=>"[{\"code\":4028,\"message\":\"3DS failure due to technical errors\"}]", "linkpay_token"=>"[FILTERED]", "linkpay_reference"=>"b9eVOGeu", "account_id"=>"EUR3D1", "order_reference"=>"1234", "payment_reference"=>"cb655389c4dd285fa8500cdc977017163d456c3a54779cb09990a1adbb05eeee", "fraud_score"=>"0", "stan"=>"", "state_3ds"=>"unknown", "payment_state"=>"failed", "transaction_time"=>"2021-12-02T12:37:30Z", "amount"=>"100.00", "customer_name"=>"oleg_hasjanov", "customer_email"=>"oleg.phenomenon@gmail.com", "invoice_number"=>"0002", "custom_field_1"=>"helllo_guys_yo", "custom_field_2"=>"", "custom_field_3"=>"", "custom_field_4"=>"", "cc_last_four_digits"=>"3438", "cc_year"=>"2024", "cc_month"=>"10", "cc_holder_name"=>"Every Pay", "cc_type"=>"master_card", "cc_issuer"=>"AS LHV Pank", "cc_funding_source"=>"Debit", "cc_cobrand"=>"", "cc_product"=>"MDS  -Debit MasterCard", "cc_issuer_country"=>"EE", "hmac"=>"14762f03cc7d21fefbe145afd1e6586137198d1133df36882d6a695b266957d3"}
# "+++++++++++++"
# #<ActionDispatch::Response:0x00007fa524371718 @mon_data=#<Monitor:0x00007fa5243716a0>, @mon_data_owner_object_id=14280, @header={"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}, @stream=#<ActionDispatch::Response::Buffer:0x00007fa5243715d8 @response=#<ActionDispatch::Response:0x00007fa524371718 ...>, @buf=[], @closed=false, @str_body=nil>, @status=200, @cv=#<MonitorMixin::ConditionVariable:0x00007fa5243714c0 @monitor=#<Monitor:0x00007fa5243716a0>, @cond=#<Thread::ConditionVariable:0x00007fa524371470>>, @committed=false, @sending=false, @sent=false, @cache_control={}, @request=#<ActionDispatch::Request POST "https://0462-85-253-148-143.ngrok.io/api/v1/callback_handler/callback_handler/callback" for 54.229.117.155>>
# "+++++++++++++"


# def callback
#   save_response
#   render status: :ok, json: { status: 'ok' }
# end
#
# def save_response
#   invoice = Invoice.find_by(number: linkpay_params[:order_reference])
#   payment_reference = linkpay_params[:payment_reference]
#
#   return unless invoice
#   return unless PaymentOrder.supported_methods.include?('PaymentOrders::EveryPay'.constantize)
#
#   payment_order = find_payment_order(invoice: invoice, ref: payment_reference)
#
#   payment_order.response = {
#     order_reference: linkpay_params[:order_reference],
#     payment_reference: linkpay_params[:payment_reference],
#   }
#   payment_order.save
#   CheckLinkpayStatusJob.set(wait: 1.minute).perform_later(payment_order.id)
# end
#
# private
#
# def find_payment_order(invoice:, ref:)
#   order = invoice.payment_orders.every_pay.for_payment_reference(ref).first
#   return order if order
#
#   PaymentOrders::EveryPay.create(invoices: [invoice], user: invoice.user)
# end
#
# def linkpay_params
#   params.permit(:order_reference, :payment_reference)
# end
#
# {
#     "account_name": "EUR3D1",
#     "order_reference": "83240",
#     "email": "oleg.hasjanov@internet.ee",
#     "customer_ip": "85.253.148.143",
#     "customer_url": null,
#     "payment_created_at": "2021-12-03T11:12:32.391Z",
#     "initial_amount": 10.0,
#     "standing_amount": 10.0,
#     "payment_reference": "ad30a1319250babbfecd296e8eac63435f69a219b4048f1e121727962ef0ffef",
#     "payment_link": "https://igw-demo.every-pay.com/lp/k5t5xq/iORPAQ5J",
#     "api_username": "ca8d6336dd750ddb",
#     "warnings": {
#         "too_many_different_cc_numbers": [
#             "Too many different card numbers has been used with the same IP address (85.253.148.143)!"
#         ],
#         "transaction_attempts_email_usage_frequency_in_hours": [
#             "Email (oleg.hasjanov@internet.ee) has been used in transaction attempts more than maximum allowed: '3'."
#         ],
#         "transaction_attempts_ip_usage_frequency_in_hours": [
#             "IP address (85.253.148.143) has been used in transaction attempts more than maximum allowed"
#         ],
#         "transaction_attempts_email_usage_frequency": [
#             "Email (oleg.hasjanov@internet.ee) has been used in transaction attempts more than maximum allowed: '5'."
#         ],
#         "transaction_attempts_ip_usage_frequency": [
#             "IP address (85.253.148.143) has been used in transaction attempts more than maximum allowed"
#         ]
#     },
#     "stan": 665795,
#     "fraud_score": 1400,
#     "payment_state": "settled",
#     "payment_method": "lhv_ob_ee",
#     "ob_details": {
#         "debtor_iban": "EE597700771001991191",
#         "creditor_iban": "EE168938346545967075",
#         "ob_payment_reference": "d3400371-5578-46e2-8076-0528888f8758",
#         "ob_payment_state": "ACSC"
#     },
#     "transaction_time": "2021-12-03T11:12:32.676Z",
#     "acquiring_completed_at": "2021-12-03 11:00:59"
# }