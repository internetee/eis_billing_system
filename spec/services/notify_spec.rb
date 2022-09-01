RSpec.describe 'Notify' do
  let(:invoice) { create(:invoice) }
  let(:user) { create(:user) }

  before(:each) do
    response_message = {
      message: 'received'
    }
    stub_request(:put, "http://registry:3000/eis_billing/payment_status")
    .to_return(status: 200, body: response_message.to_json, headers: {})
    stub_request(:put, "http://auction_center:3000/eis_billing/payment_status")
    .to_return(status: 200, body: response_message.to_json, headers: {})
    stub_request(:put, "http://eeid:3000/eis_billing/payment_status")
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
        order_reference: invoice.invoice_number,
        payment_reference: 'test',
      }

      notifier = Notify.new(response: JSON.parse(everypay_response.to_json))
      notifier.call
      invoice.reload

      expect(invoice.status).to eq('paid')
    end

    it 'should mark multiple invoices as paid' do
      invoice_one.save
      invoice_two.save

      invoice_three.description = "#{invoice_one.invoice_number} #{invoice_two.invoice_number}"
      invoice_three.save

      expect(invoice_three.description).to eq("#{invoice_one.invoice_number} #{invoice_two.invoice_number}")
      expect(invoice_one.status).to eq('unpaid')
      expect(invoice_two.status).to eq('unpaid')
      expect(invoice_three.status).to eq('unpaid')


      everypay_response = {
        payment_state: 'settled',
        transaction_time: Time.zone.now - 1.hour,
        order_reference: invoice_three.invoice_number,
        payment_reference: 'test',
      }

      notifier = Notify.new(response: JSON.parse(everypay_response.to_json))
      notifier.call

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
        payment_reference: 'test',
      }

      notifier = Notify.new(response: JSON.parse(everypay_response.to_json))
      mailer = notifier.call

      expect(mailer.subject).to eq("Invoice not found")
      expect(mailer.body). to include("Invoice with no_exists number not found")
    end
  end
end
