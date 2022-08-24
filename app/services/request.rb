module Request
  include Connection

  def get(path, params = {})
    respond_with(
      connection.get(path, params)
    )
  end

  def post(path, params = {})
    respond_with(
      connection.post(path, JSON.dump(params))
    )
  end

  def put_request(path, params = {})
    respond_with(
      connection.put(path, JSON.dump(params))
    )
  end

  private

  def respond_with(response)
    JSON.parse response.body
  end
end

