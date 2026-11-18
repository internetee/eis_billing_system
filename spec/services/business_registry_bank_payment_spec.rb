require 'rails_helper'

RSpec.describe BusinessRegistryBankPayment do
  let(:reference) { Reference.create!(reference_number: '1234561', initiator: 'business_registry', owner: 'user-uuid') }
  let!(:invoice) do
    Invoice.create!(invoice_number: 150_123, initiator: 'business_registry', transaction_amount: '20.0',
                    reference_number: '1234561', status: :unpaid)
  end
  let(:date) { Date.new(2026, 10, 16) }
  let(:transaction) do
    OpenStruct.new(amount: '20.00', currency: 'EUR', date:, payment_reference_number: '1234561',
                   payment_description: 'Domain reservation 1234561')
  end
  let(:mailer) { double('mailer', deliver_now: true) }
  let(:expected_body) do
    { reference_number: '1234561', invoice_number: '150123', amount: '20.0', currency: 'EUR', paid_at: '2026-10-16' }
  end

  def call
    described_class.call(reference:, transactions: [transaction])
  end

  it 'marks invoice paid and notifies registry with service token' do
    request = stub_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)
              .with(body: expected_body.to_json) do |req|
                token = req.headers['Authorization'].delete_prefix('Bearer ')
                JWT.decode(token, GlobalVariable::BILLING_SECRET).first == { 'initiator' => 'billing' } &&
                  req.headers['Content-Type'] == 'application/json'
              end
              .to_return(status: 200, body: { message: 'Payment processed' }.to_json)
    expect(NotifierMailer).not_to receive(:inform_admin)

    call

    expect(request).to have_been_requested.once
    expect(invoice.reload).to be_paid
    expect(invoice.transaction_time.to_date).to eq(date)
  end

  it 'informs admin and keeps invoice unpaid when amount mismatches' do
    transaction.amount = '19.99'
    expect(NotifierMailer).to receive(:inform_admin).with('Business registry payment mismatch', anything)
                                                    .and_return(mailer)

    call

    expect(invoice.reload).to be_unpaid
    expect(a_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)).not_to have_been_made
  end

  it 'informs admin when currency is not EUR' do
    transaction.currency = 'USD'
    expect(NotifierMailer).to receive(:inform_admin).with('Business registry payment mismatch', anything)
                                                    .and_return(mailer)

    call

    expect(invoice.reload).to be_unpaid
  end

  it 'informs admin about duplicate payment for already paid invoice' do
    invoice.update!(status: :paid)
    expect(NotifierMailer).to receive(:inform_admin).with('Business registry invoice already paid', anything)
                                                    .and_return(mailer)

    call

    expect(a_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)).not_to have_been_made
  end

  it 'informs admin when invoice is not found' do
    invoice.update!(reference_number: nil)
    expect(NotifierMailer).to receive(:inform_admin).with('Business registry invoice not found', anything)
                                                    .and_return(mailer)

    call

    expect(a_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)).not_to have_been_made
  end

  it 'cancels invoice and asks admin to refund when registry cannot reserve domains' do
    stub_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)
      .to_return(status: 422, body: { message: 'Failed to reserve domains' }.to_json)
    expect(NotifierMailer).to receive(:inform_admin)
      .with('Business registry reservation is not possible, payment must be refunded',
            /invoice status: cancelled.*amount: 20.00 EUR.*Failed to reserve domains/)
      .and_return(mailer)

    call

    expect(invoice.reload).to be_cancelled
  end

  it 'informs admin and keeps invoice paid when registry fails unexpectedly' do
    stub_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL)
      .to_return(status: 500, body: { message: 'Internal error' }.to_json)
    expect(NotifierMailer).to receive(:inform_admin)
      .with('Registry rejected business registry payment with status 500', /Internal error/)
      .and_return(mailer)

    call

    expect(invoice.reload).to be_paid
  end

  it 'informs admin when registry is unavailable' do
    stub_request(:put, GlobalVariable::BUSINESS_REGISTRY_PAYMENT_URL).to_raise(Errno::ECONNREFUSED)
    expect(NotifierMailer).to receive(:inform_admin)
      .with('Registry is unavailable for business registry payment', anything)
      .and_return(mailer)

    call

    expect(invoice.reload).to be_paid
  end
end
