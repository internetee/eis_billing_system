require 'rails_helper'

RSpec.describe InvoicePdfGenerator do
  subject(:generator) { described_class.new(payload.deep_stringify_keys) }

  let(:payload) do
    {
      invoice: {
        number: '26000123', issue_date: '2026-10-01', due_date: '2026-10-15',
        cancelled_at: nil, description: 'Registry services', reference_no: '1234561',
        currency: 'EUR', vat_rate: '22', total: '1525.61', monthly_invoice: false,
        buyer_name: 'Example Registrar OÜ', buyer_reg_no: '12345678', buyer_vat_no: 'EE123456789',
        buyer_street: 'Buyer Street 2', buyer_city: 'Tartu', buyer_state: '', buyer_zip: '51011',
        buyer_country_code: 'EE', buyer_phone: '+372 5555 1234',
        buyer_url: 'https://buyer.example', buyer_email: 'billing@buyer.example',
        seller_name: 'Eesti Interneti SA', seller_reg_no: '90010019', seller_vat_no: 'EE101286464',
        seller_street: 'Paldiski mnt 80', seller_city: 'Tallinn', seller_state: 'Harjumaa',
        seller_zip: '10617', seller_country_code: 'EE', seller_phone: '+372 727 1000',
        seller_email: 'info@internet.ee', seller_url: 'https://internet.ee',
        seller_bank: 'LHV Pank', seller_iban: 'EE111111111111111111', seller_swift: 'LHVBEE22'
      },
      items: [
        { description: 'Domain registrations', unit: 'pcs', quantity: '2', price: '625.25',
          subtotal: '1250.50', vat_rate: '22', vat_amount: '275.11', total: '1525.61' }
      ],
      invoice_subtotal: '1250.50', vat_amount: '275.11'
    }
  end

  describe '#html' do
    it 'renders registry invoice details, addresses, labels and formatted amounts when unpaid' do
      html = generator.html

      expect(html).to include('Invoice no. 26000123', 'Example Registrar OÜ', 'Domain registrations',
                             'Buyer Street 2, Tartu, 51011', 'Paldiski mnt 80, Tallinn, Harjumaa, 10617',
                             'Estonia', 'Reference number', 'VAT number', 'Quantity', 'Receipt date',
                             '625,25', '1250,50 EUR', "1 250,50\u00a0€", "275,11\u00a0€",
                             "1 525,61\u00a0€", 'Unpaid')
      expect(Nokogiri::HTML(html).css('tbody tr td')[2].text).to eq('2')
    end

    it 'also accepts symbol keys' do
      expect(described_class.new(payload).html).to include('Example Registrar OÜ', 'Domain registrations')
    end

    it 'shows the receipt date from the paid billing invoice' do
      create(:invoice, invoice_number: payload[:invoice][:number], status: :paid,
                       transaction_time: Time.zone.local(2026, 10, 10, 12))

      expect(generator.html).to include('2026-10-10')
      expect(generator.html).not_to include('Unpaid')
    end

    it 'shows cancellation and its date from the payload' do
      payload[:invoice][:cancelled_at] = '2026-10-12T14:30:00Z'

      expect(generator.html).to include('Cancelled', '2026-10-12')
      expect(generator.html).not_to include('Unpaid')
    end

    it 'shows cancellation from billing even without a cancellation date in the payload' do
      create(:invoice, invoice_number: payload[:invoice][:number], status: :cancelled)

      expect(generator.html).to include('Cancelled')
      expect(generator.html).not_to include('Unpaid')
    end

    it 'renders monthly header rows without amounts and preserves the monthly zero totals' do
      payload[:invoice][:monthly_invoice] = true
      payload[:items].unshift(description: 'Credit account activities')
      html = generator.html
      rows = Nokogiri::HTML(html).css('tbody tr')

      expect(rows.first.css('td').map(&:text)).to eq(['Credit account activities', '', '', '', ''])
      expect(rows.last.text).to include('Domain registrations', '625,25', '1250,50 EUR')
      expect(Nokogiri::HTML(html).css('tfoot td').map(&:text)).to eq(["0,00\u00a0€"] * 3)
      expect(html).not_to include('Receipt date', 'Payment term')
    end
  end

  describe '#as_pdf' do
    it 'generates a PDF document' do
      expect(generator.as_pdf).to start_with('%PDF')
    end
  end
end
