module InvoiceGenerator
  extend self

  def run(params)
    invoice = GenerateInvoiceInstance.process(params)
    link = EverypayLinkGenerator.create(invoice: invoice)
    # BillingMailer.invoice_email(invoice: invoice).deliver_now
    # PdfGenerator.generate(invoice: invoice)

    link
  end


end