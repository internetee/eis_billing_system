require 'rails_helper'

RSpec.describe SaveInvoiceDataJob, type: :job do
  it 'adds new invoices and skips duplicates or missing numbers' do
    ActiveJob::Base.queue_adapter = :test
    response = [
      { 'invoice_number' => '200', 'initiator' => 'registry', 'transaction_amount' => '10.0', 'status' => 'issued' },
      { 'invoice_number' => nil },
      { 'invoice_number' => '200', 'initiator' => 'registry', 'transaction_amount' => '10.0', 'status' => 'paid' }
    ]

    added, skipped = described_class.perform_now(response)

    expect(added).to eq(1)
    expect(skipped).to eq(2)
    expect(Invoice.find_by(invoice_number: '200')).to be_present
  end
end


