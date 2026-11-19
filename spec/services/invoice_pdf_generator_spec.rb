require 'rails_helper'

RSpec.describe InvoicePdfGenerator do
  subject(:generator) { described_class.new(invoice) }

  let(:invoice) do
    create(:invoice, invoice_number: 26000123, status: :unpaid, transaction_amount: '42.50',
                     created_at: Time.zone.local(2026, 9, 28, 12), description: 'Registry services',
                     directo_data: directo_data, linkpay_info: linkpay_info, everypay_response: everypay_response)
  end
  let(:directo_data) { "<invoices>#{directo_invoice}</invoices>" }
  let(:directo_invoice) do
    <<~XML
      <invoice Number="26000123" InvoiceDate="2026-10-01" CustomerCode="12345678"
               CustomerName="Example Registrar OÜ" VATregNo="EE123456789" Destination="EE"
               Currency="EUR" TotalWoVAT="1250.50" TotalVAT="300.12">
        <line ProductName="Domain registrations" Unit="pcs" Quantity="2" UnitPriceWoVAT="625.25"/>
      </invoice>
    XML
  end
  let(:linkpay_info) { {} }
  let(:everypay_response) { {} }
  let(:seller_settings) do
    {
      registry_juridical_name: 'Eesti Interneti SA', registry_reg_no: '90010019', registry_vat_no: 'EE101286464',
      registry_street: 'Paldiski mnt 80', registry_city: 'Tallinn', registry_state: ' ', registry_zip: '10617',
      registry_country_code: 'EE', registry_phone: '+372 727 1000', registry_email: 'info@internet.ee',
      registry_url: 'https://internet.ee', registry_bank: 'LHV Pank',
      registry_iban: 'EE111111111111111111', registry_swift: 'LHVBEE22'
    }
  end

  before do
    seller_settings.each do |code, value|
      SettingEntry.create!(code: code, value: value, format: 'string', group: 'registry')
    end
  end

  describe '#html' do
    subject(:html) { generator.html }

    let(:document) { Nokogiri::HTML(html) }

    it 'renders the Directo buyer, items, issue date and totals with the calculated VAT rate' do
      expect(html).to include('Invoice no. 26000123', '2026-10-01', 'Example Registrar OÜ', '12345678',
                             'EE123456789', 'Estonia', 'Registry services', 'Payment term', 'Prepayment')
      expect(html).not_to include('2026-09-28', 'Due date', 'Reference number', 'Cancelled at')
      expect(document.css('tbody tr td').map(&:text)).to eq(
        ['Domain registrations', 'pcs', '2', '625,25', '1250,50 EUR']
      )
      expect(document.css('tfoot th').map(&:text).map(&:strip)).to include('Subtotal', 'VAT 24.0%', 'Total')
      expect(document.css('tfoot td').map(&:text)).to eq(["1 250,50\u00a0€", "300,12\u00a0€", "1 550,62\u00a0€"])
    end

    it 'selects the matching invoice from a Directo batch' do
      other_invoice = directo_invoice.sub('Number="26000123"', 'Number="26000124"')
                                     .sub('Example Registrar OÜ', 'Other buyer')
                                     .sub('Domain registrations', 'Other services')
      invoice.update!(directo_data: "<invoices>#{other_invoice}#{directo_invoice}</invoices>")

      expect(html).to include('Example Registrar OÜ', 'Domain registrations')
      expect(html).not_to include('Other buyer', 'Other services')
    end

    it 'uses the billing record when no Directo invoice number matches' do
      invoice.update!(directo_data: directo_data.sub('Number="26000123"', 'Number="26000124"'))

      expect(html).to include('2026-09-28', 'Registry services', '42,50 EUR')
      expect(html).not_to include('Example Registrar OÜ', 'Domain registrations', 'Subtotal', 'VAT 24.0%')
      expect(document.css('tfoot tr').size).to eq(1)
    end

    it 'uses the Directo currency for line amounts and totals' do
      invoice.update!(directo_data: directo_data.sub('Currency="EUR"', 'Currency="USD"'))

      expect(document.css('tbody').text).to include('1250,50 USD')
      expect(document.css('tfoot td').map(&:text)).to eq(
        ["1 250,50\u00a0USD", "300,12\u00a0USD", "1 550,62\u00a0USD"]
      )
    end

    it 'handles a zero Directo subtotal without dividing by zero' do
      invoice.update!(directo_data: directo_data.sub('TotalWoVAT="1250.50"', 'TotalWoVAT="0"')
                                               .sub('TotalVAT="300.12"', 'TotalVAT="0"'))

      expect(document.css('tfoot').text).to include('VAT 0.0%')
      expect(document.css('tfoot td').map(&:text)).to eq(["0,00\u00a0€"] * 3)
    end

    it 'shows the receipt date for a paid invoice' do
      invoice.update!(status: :paid, transaction_time: Time.zone.local(2026, 10, 10, 12))

      expect(html).to include('Receipt date', '2026-10-10')
      expect(html).not_to include('Unpaid', 'Cancelled')
    end

    it 'shows Cancelled for a cancelled invoice' do
      invoice.update!(status: :cancelled)

      expect(html).to include('Cancelled')
      expect(html).not_to include('Unpaid', 'Cancelled at')
    end

    it 'shows Unpaid for an unpaid invoice' do
      expect(html).to include('Unpaid')
      expect(html).not_to include('Cancelled')
    end

    it 'renders seller requisites from settings, omitting blank address components' do
      expect(document.at_css('#footer').text).to include(
        'Eesti Interneti SA', 'Paldiski mnt 80, Tallinn, 10617', 'Estonia', 'Reg. no 90010019',
        'VAT number EE101286464', '+372 727 1000', 'info@internet.ee', 'https://internet.ee',
        'LHV Pank', 'EE111111111111111111', 'LHVBEE22'
      )
    end

    context 'without Directo data' do
      let(:directo_data) { nil }
      let(:linkpay_info) { { 'customer_name' => 'Linkpay customer', 'customer_email' => 'customer@example.test' } }
      let(:everypay_response) { { 'email' => 'payer@example.test' } }

      it 'renders the Linkpay customer and one item with only the billing total' do
        expect(html).to include('Linkpay customer', 'customer@example.test', '2026-09-28')
        expect(html).not_to include('payer@example.test')
        expect(document.css('tbody tr td').map(&:text)).to eq(
          ['Registry services', '', '1', '42,50', '42,50 EUR']
        )
        expect(document.css('tfoot tr').size).to eq(1)
        expect(document.css('tfoot').text).to include('Total')
        expect(document.css('tfoot').text).not_to include('Subtotal', 'VAT')
        expect(document.css('tfoot td').map(&:text)).to eq(["42,50\u00a0€"])
      end

      it 'falls back to the Everypay email when the Linkpay email is blank' do
        invoice.update!(linkpay_info: { 'customer_name' => 'Linkpay customer', 'customer_email' => ' ' })

        expect(html).to include('Linkpay customer', 'payer@example.test')
      end

      it 'uses the Everypay email when Linkpay data is missing' do
        invoice.update!(linkpay_info: nil)

        expect(html).to include('payer@example.test')
        expect(document.css('dl').last.css('dt').map(&:text)).to eq(['E-mail'])
      end

      it 'uses the invoice number as the item description when the description is blank' do
        invoice.update!(description: ' ')

        expect(document.at_css('tbody tr td').text).to eq('Invoice 26000123')
      end

      context 'with blank buyer fields and seller settings' do
        let(:linkpay_info) { { 'customer_name' => ' ', 'customer_email' => '' } }
        let(:everypay_response) { nil }
        let(:seller_settings) { super().transform_values { ' ' } }

        it 'omits blank values and their labels' do
          expect(document.css('dl').last.css('dt, dd')).to be_empty
          expect(document.at_css('#footer').text.strip).to be_empty
        end
      end

      context 'with no buyer data or seller settings' do
        let(:linkpay_info) { nil }
        let(:everypay_response) { nil }
        let(:seller_settings) { {} }

        it 'renders without empty party labels' do
          expect(document.css('dl').last.css('dt, dd')).to be_empty
          expect(document.at_css('#footer').text.strip).to be_empty
        end
      end
    end
  end

  describe '#as_pdf' do
    it 'generates a PDF document' do
      expect(generator.as_pdf).to start_with('%PDF')
    end
  end

  describe '#filename' do
    it 'includes the billing invoice number' do
      expect(generator.filename).to eq('Invoice-26000123.pdf')
    end
  end
end
