class InvoicePdfGenerator
  attr_reader :invoice, :items, :subtotal, :vat_amount, :total

  def initialize(params)
    params = params.with_indifferent_access
    @invoice = params.fetch(:invoice)
    @items = params.fetch(:items)
    @subtotal = params[:invoice_subtotal].to_d
    @vat_amount = params[:vat_amount].to_d
    @total = invoice[:total].to_d
    @billing_invoice = ::Invoice.find_by(invoice_number: invoice[:number])
  end

  def html
    template = invoice[:monthly_invoice] ? 'invoice_pdfs/monthly_pdf' : 'invoice_pdfs/pdf'
    ActionController::Base.render(template: template, layout: false, assigns: { pdf: self })
  end

  def as_pdf
    PDFKit.new(html, enable_local_file_access: true).to_pdf
  end

  def to_s
    I18n.t('invoice_no', no: invoice[:number])
  end

  def currency(amount)
    format('%01.2f', amount.to_d.round(2)).sub('.', ',')
  end

  def paid?
    @billing_invoice&.paid?
  end

  def cancelled?
    invoice[:cancelled_at].present? || @billing_invoice&.cancelled?
  end

  def receipt_date
    @billing_invoice&.transaction_time&.to_date if paid?
  end

  %i[issue_date due_date cancelled_at].each do |field|
    define_method(field) { Date.parse(invoice[field].to_s) if invoice[field].present? }
  end

  %i[seller buyer].each do |party|
    define_method("#{party}_address") do
      %i[street city state zip].map { |field| invoice["#{party}_#{field}"] }.compact_blank.join(', ')
    end

    define_method("#{party}_country") do
      ISO3166::Country.new(invoice["#{party}_country_code"])&.to_s
    end
  end
end
