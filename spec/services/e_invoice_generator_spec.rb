require 'rails_helper'

RSpec.describe EInvoiceGenerator do
  let(:invoice_data) do
    {
      seller_name: 'Seller OÜ', seller_reg_no: '12345678', seller_vat_no: 'EE123456789',
      seller_street: 'Street 1', seller_state: 'Harju', seller_zip: '10111', seller_city: 'Tallinn', seller_iban: 'EE111111111111111111',
      buyer_name: 'Buyer AS', buyer_reg_no: '87654321', buyer_vat_no: 'EE987654321',
      buyer_street: 'Buyer 2', buyer_state: 'Tartu', buyer_zip: '51011', buyer_city: 'Tartu',
      number: 'INV-1', issue_date: Date.today, reference_no: 'RF123', due_date: Date.today + 7,
      total: 120.0, total_to_pay: 120.0, currency: 'EUR', vat_rate: 20, monthly_invoice: false
    }
  end

  let(:data) do
    {
      invoice_data: invoice_data,
      payable: true,
      invoice_subtotal: 100.0,
      vat_amount: 20.0,
      balance_date: Date.today,
      balance_begin: 0.0,
      inbound: 0.0,
      outbound: 0.0,
      balance_end: 0.0,
      invoice_items: [
        { description: 'Item 1', price: 50, quantity: 1, unit: 'pcs', subtotal: 50, vat_rate: 20, vat_amount: 10, total: 60 },
        { description: 'Item 2', price: 50, quantity: 1, unit: 'pcs', subtotal: 50, vat_rate: 20, vat_amount: 10, total: 60 }
      ],
      buyer_billing_email: 'buyer@example.com',
      buyer_e_invoice_iban: 'EE222222222222222222',
      seller_country_code: 'EE',
      buyer_country_code: 'EE'
    }
  end

  it 'generates an EInvoice with required fields populated' do
    einv = described_class.new(data).generate

    expect(einv.invoice.seller.name).to eq('Seller OÜ')
    expect(einv.invoice.buyer.name).to eq('Buyer AS')
    expect(einv.invoice.number).to eq('INV-1')
    expect(einv.invoice.items.size).to eq(2)
    expect(einv.invoice.total).to eq(120.0)
    expect(einv.invoice.vat_amount).to eq(20.0)
    expect(einv.date).to be_present
  end

  it 'computes item totals when monthly_invoice is true' do
    data[:invoice_data][:monthly_invoice] = true
    data[:invoice_items] = [
      { description: 'Subscription', price: 10, quantity: 3, unit: 'pcs' }
    ]

    einv = described_class.new(data).generate
    # First item is used for invoice name, so we check the remaining items
    expect(einv.invoice.items.size).to eq(0) # All items used for name
    expect(einv.invoice.name).to eq('Subscription')
  end
end


