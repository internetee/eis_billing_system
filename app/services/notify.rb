class Notify
  attr_reader :response

  def initialize
  end

  def update(response)
    @response = response
    display
  end

  def display
    # p "++++ response eis billing +++"
    # p @response
    # p "+++++++++++++++++++++++++++++"

    base_request(params: @response)
  end

  def base_request(params:)
    uri = URI.parse(update_payment_url)
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
    ENV['update_payment_url']
  end
end
