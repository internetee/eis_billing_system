class PaymentResponseModelWrapper
  attr_reader :response

  def initialize
  end

  def update(response)
    update_invoice_state(order_reference: response[:order_reference], payment_state: response[:payment_state], transaction_time: response[:transaction_time])

    @response = OpenStruct.new(response: response)
    display
  end

  def display
    p "Payment Response Model Wrapper ========="
    p @response
    p "========================================"
  end

  private

  def update_invoice_state(order_reference:, payment_state:, transaction_time:)
    invoice = Invoice.find_by(invoice_number: order_reference)

    return if invoice.nil?

    if payment_state == 'settled'
      invoice.update(status: :paid, paid_at: transaction_time)
    else
      invoice.update(status: :failed)
    end

    p "++++++ UPDATED INVOICE +++++"
    p invoice
    p "++++++++++++++++++++++++++++"
  end
end
