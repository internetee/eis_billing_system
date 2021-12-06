class PaymentResponseModelWrapper
  attr_reader :response

  def initialize
  end

  def update(response)
    @response = OpenStruct.new(response: response)
    display
  end

  def display
    p "Payment Response Model Wrapper ========="
    p @response
    p "========================================"
  end
end
