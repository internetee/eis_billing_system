class PaymentResponseModelWrapper
  attr_reader :response

  def initialize
  end

  def update(response)
    update_invoice_state(order_reference: response[:order_reference], payment_state: response[:payment_state])

    @response = OpenStruct.new(response: response)
    display
  end

  def display
    p "Payment Response Model Wrapper ========="
    p @response
    p "========================================"
  end

  private

  def update_invoice_state(order_reference:, payment_state:)
    invoice = Invoice.find_by(order_reference: order_reference)

    return if invoice.nil?
    
    invoice.update(status: :paid)

    p "++++++ UPDATED INVOICE +++++"
    p invoice
    p "++++++++++++++++++++++++++++"
  end
end
