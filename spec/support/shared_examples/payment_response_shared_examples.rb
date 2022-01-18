RSpec.shared_examples 'should update payment status' do
  let(:invoice) { create(:invoice) }
  let(:user) { create(:user) }

  it 'it should set that payment was paid succesfully' do
    response = {
      account_name: 'EUR',
      order_reference: invoice.invoice_number,
      email: user.email,
      customer_ip: '12.32.12.12',
      customer_url: 'http://eis.ee',
      payment_created_at: Time.zone.now - 10.hours,
      initial_amount: 123.32,
      standing_amount: 123.32,
      payment_reference: '234343423423423asd',
      payment_link: 'http://everypay.link',
      api_username: 'some-api',
      warnings: [],
      stan: 'stab',
      fraud_score: 'fraud_score',
      payment_state: 'settled',
      payment_method: 'everypay',
      ob_details: 'ob_details',
      creditor_iban: '23323123323123',
      ob_payment_reference: '213123123',
      ob_payment_state: '213123123',
      transaction_time: Time.zone.now - 1.hour
    }

    payment_response_model_wrapper = PaymentResponseModelWrapper.new
    payment_response_model_wrapper.update(response)

    invoice.reload

    expect(invoice.status).to eq('paid')
  end

  it 'it should set that payment was paid failly' do
    response = {
      account_name: 'EUR',
      order_reference: invoice.invoice_number,
      email: user.email,
      customer_ip: '12.32.12.12',
      customer_url: 'http://eis.ee',
      payment_created_at: Time.zone.now - 10.hours,
      initial_amount: 123.32,
      standing_amount: 123.32,
      payment_reference: '234343423423423asd',
      payment_link: 'http://everypay.link',
      api_username: 'some-api',
      warnings: [],
      stan: 'stab',
      fraud_score: 'fraud_score',
      payment_state: 'failed',
      payment_method: 'everypay',
      ob_details: 'ob_details',
      creditor_iban: '23323123323123',
      ob_payment_reference: '213123123',
      ob_payment_state: '213123123',
      transaction_time: Time.zone.now - 1.hour
    }

    payment_response_model_wrapper = PaymentResponseModelWrapper.new
    payment_response_model_wrapper.update(response)

    invoice.reload

    expect(invoice.status).to eq('failed')
  end
end
