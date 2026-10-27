class InvoicePdfGenerator
  attr_reader :invoice, :buyer, :items, :issue_date, :currency_code, :subtotal, :vat_amount, :vat_rate, :total

  def initialize(invoice)
    @invoice = invoice
    directo_invoice = Nokogiri::XML(invoice.directo_data).xpath('//invoice').find do |node|
      node['Number'] == invoice.invoice_number.to_s
    end if invoice.directo_data.present?

    directo_invoice ? load_directo_invoice(directo_invoice) : load_billing_invoice
  end

  def html
    ActionController::Base.render(template: 'invoice_pdfs/pdf', layout: false, assigns: { pdf: self })
  end

  def as_pdf
    PDFKit.new(html, enable_local_file_access: true).to_pdf
  end

  def filename
    "Invoice-#{invoice.invoice_number}.pdf"
  end

  def to_s
    I18n.t('invoice_no', no: invoice.invoice_number)
  end

  def currency(amount)
    format('%01.2f', amount.to_d.round(2)).sub('.', ',')
  end

  def paid?
    invoice.paid?
  end

  def cancelled?
    invoice.cancelled?
  end

  def receipt_date
    invoice.transaction_time&.to_date if paid?
  end

  def seller
    @seller ||= {
      name: Setting.registry_juridical_name,
      reg_no: Setting.registry_reg_no,
      vat_no: Setting.registry_vat_no,
      address: [Setting.registry_street, Setting.registry_city, Setting.registry_state,
                Setting.registry_zip].compact_blank.join(', '),
      country: ISO3166::Country.new(Setting.registry_country_code)&.to_s,
      email: Setting.registry_email,
      phone: Setting.registry_phone,
      url: Setting.registry_url,
      bank: Setting.registry_bank,
      iban: Setting.registry_iban,
      swift: Setting.registry_swift
    }
  end

  private

  def load_directo_invoice(node)
    @issue_date = Date.parse(node['InvoiceDate']) if node['InvoiceDate'].present?
    @buyer = {
      name: node['CustomerName'], reg_no: node['CustomerCode'], vat_no: node['VATregNo'],
      country: ISO3166::Country.new(node['Destination'])&.to_s
    }
    @currency_code = node['Currency']
    @items = node.xpath('line').map do |line|
      price = line['UnitPriceWoVAT'].to_d
      { description: line['ProductName'], unit: line['Unit'], quantity: line['Quantity'],
        price: price, total: price * line['Quantity'].to_d }
    end
    @subtotal = node['TotalWoVAT'].to_d
    @vat_amount = node['TotalVAT'].to_d
    @vat_rate = subtotal.zero? ? 0 : (vat_amount / subtotal * 100).round(1)
    @total = subtotal + vat_amount
  end

  def load_billing_invoice
    linkpay_info = invoice.linkpay_info || {}
    @issue_date = invoice.created_at.to_date
    @buyer = {
      name: linkpay_info['customer_name'],
      email: linkpay_info['customer_email'].presence || (invoice.everypay_response || {})['email']
    }
    @currency_code = 'EUR'
    @total = invoice.transaction_amount.to_d
    @items = [{ description: invoice.description.presence || "Invoice #{invoice.invoice_number}",
                quantity: 1, price: total, total: total }]
  end
end
