class Notify
  attr_reader :response

  def initialize
  end

  def update(response)
    @response = response
    display
  end

  def display
    p "++++ response eis billing +++"
    p @response
    p "+++++++++++++++++++++++++++++"

    base_request(params: @response)
  end

  def base_request(params:)
    uri = URI(update_payment_url)
    http = Net::HTTP.new(uri.host, uri.port)
    headers = {
      'Authorization'=>'Bearer foobar',
      'Content-Type' =>'application/json'
      # 'Accept'=> TOKEN
    }

    res = http.put(update_payment_url, params.to_json, headers)
    res
  end

  def update_payment_url
    "https://registry:3000/eis_billing/payment_status"
  end
end
