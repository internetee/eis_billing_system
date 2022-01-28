module InvoiceGenerator
  extend self

  def run(params)
    # BillingMailer.invoice_email(invoice: invoice).deliver_now
    # PdfGenerator.generate(invoice: invoice)

    InvoiceInstanceGenerator.create(params: params)
    EverypayLinkGenerator.create(params: params)
  end
end
