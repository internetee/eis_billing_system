require 'rails_helper'

RSpec.describe 'Notify' do
  let(:invoice) { create(:invoice) }
  let(:user) { create(:user) }

  before(:each) do
    response_message = {
      message: 'request successfully received'
    }
    stub_request(:put, "#{GlobalVariable::BASE_REGISTRY}/eis_billing/payment_status")
      .to_return(status: 200, body: response_message.to_json, headers: {})
    stub_request(:put, "#{GlobalVariable::BASE_AUCTION}/eis_billing/payment_status")
      .to_return(status: 200, body: response_message.to_json, headers: {})
    stub_request(:put, "#{GlobalVariable::BASE_EEID}/eis_billing/payment_status")
      .to_return(status: 200, body: response_message.to_json, headers: {})
  end

  describe 'payment process' do
    let(:invoice_one) { build(:invoice, invoice_number: 10, payment_reference: 'ten', initiator: 'auction') }
    let(:invoice_two) { build(:invoice, invoice_number: 20, payment_reference: 'twenty', initiator: 'auction') }
    let(:invoice_three) { build(:invoice, invoice_number: 30, payment_reference: 'threety', initiator: 'auction') }

    it 'should mark single invoice as paid if settled' do
      invoice.initiator = 'registry'
      invoice.invoice_number = 3
      invoice.save
      expect(invoice.initiator).to eq('registry')
      expect(invoice.status).to eq('unpaid')

      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: invoice.invoice_number.to_s,
        payment_reference: 'test',
        initial_amount: invoice.transaction_amount
      }

      Notify.call(response: JSON.parse(everypay_response.to_json))
      invoice.reload

      expect(invoice.status).to eq('paid')
    end

    it 'should mark single invoice as partially_paid if settled and not fully paid' do
      invoice.initiator = 'auction'
      invoice.invoice_number = 3
      invoice.save
      expect(invoice.initiator).to eq('auction')
      expect(invoice.status).to eq('unpaid')

      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: invoice.invoice_number.to_s,
        payment_reference: 'test',
        initial_amount: invoice.transaction_amount.to_f - 1
      }

      Notify.call(response: JSON.parse(everypay_response.to_json))
      invoice.reload

      expect(invoice.status).to eq('partially_paid')
    end

    it 'should mark multiple invoices as paid' do
      invoice_one.save
      invoice_two.save

      invoice_one.update(initiator: 'auction')
      invoice_two.update(initiator: 'auction')
      invoice_three.update(initiator: 'auction')

      invoice_three.description = "#{invoice_one.invoice_number} #{invoice_two.invoice_number}"
      invoice_three.save

      invoice_one.reload && invoice_two.reload && invoice_three.reload

      expect(invoice_three.description).to eq("#{invoice_one.invoice_number} #{invoice_two.invoice_number}")
      expect(invoice_one.status).to eq('unpaid')
      expect(invoice_two.status).to eq('unpaid')
      expect(invoice_three.status).to eq('unpaid')

      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: "ref:#{invoice_three.invoice_number}, #{invoice_three.description.split(' ').join(', ')}",
        payment_reference: 'test',
        initial_amount: invoice_three.transaction_amount
      }

      Notify.call(response: JSON.parse(everypay_response.to_json))

      invoice_one.reload
      invoice_two.reload
      invoice_three.reload

      expect(invoice_three.status).to eq('paid')
      expect(invoice_one.status).to eq('paid')
      expect(invoice_two.status).to eq('paid')
    end
  end

  describe 'email notifier' do
    let!(:admin) { create(:user) }

    it 'should notify admin that invoice not found' do
      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: 'no_exists',
        payment_reference: 'test'
      }

      mailer = Notify.call(response: JSON.parse(everypay_response.to_json))

      expect(mailer.subject).to eq("Invoice with #{everypay_response[:order_reference]} number not found")
      expect(mailer.body).to include("Invoice with #{everypay_response[:order_reference]} number not found")
    end
  end

  context 'auction prepayment' do
    it 'should handle invoice as auction prepayment deposit' do
      request_data =  {
        domain_name: 'toto.ee',
        user_uuid: 'ffg4e',
        user_email: 'wow@test.ee',
        transaction_amount: invoice.transaction_amount.to_f,
        description: 'deposit'
      }

      invoice.initiator = 'auction'
      invoice.invoice_number = 1
      invoice.description = 'auction_deposit toto.ee, user_uuid ffg4e, user_email wow@test.ee'
      invoice.save
      invoice.reload

      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: invoice.invoice_number.to_s,
        payment_reference: 'test',
        initial_amount: invoice.transaction_amount
      }

      response = Notify.call(response: JSON.parse(everypay_response.to_json))
      invoice.reload

      expect(response['message']).to eq 'request successfully received'
      expect(invoice.status).to eq('paid')
    end
  end
end
