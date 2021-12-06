module ParseResponse
  extend self

  def call(response)
    @response = parse_response(response)

    # Subject
    concrete_subject = ConcreteSubject.new(@response)

    # Observers
    payment_response_model_wrapper = PaymentResponseModelWrapper.new
    notification = Notify.new

    concrete_subject.attach(payment_response_model_wrapper)
    concrete_subject.attach(notification)

    concrete_subject.notify
  end

  private

  def parse_response(response)
    {
      account_name: response['account_name'],
      order_reference: response['order_reference'],
      email: response['email'],
      customer_ip: response['customer_ip'],
      customer_url: response['customer_url'],
      payment_created_at: response['payment_created_at'],
      initial_amount: response['initial_amount'],
      standing_amount: response['standing_amount'],
      payment_reference: response['payment_reference'],
      payment_link: response['payment_link'],
      api_username: response['api_username'],
      warnings: response['warnings'],
      stan: response['stan'],
      fraud_score: response['fraud_score'],
      payment_state: response['payment_state'],
      payment_method: response['payment_method'],
      ob_details: response['ob_details'],
      creditor_iban: response['creditor_iban'],
      ob_payment_reference: response['ob_payment_reference'],
      ob_payment_state: response['ob_payment_state'],
      transaction_time: response['transaction_time']
    }
  end
end
