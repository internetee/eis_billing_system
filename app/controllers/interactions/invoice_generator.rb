module InvoiceGenerator
  extend self

  def run(params)
    # invoice = GenerateInvoiceInstance.process(params)
    # BillingMailer.invoice_email(invoice: invoice).deliver_now
    # PdfGenerator.generate(invoice: invoice)

    EverypayLinkGenerator.create(params: params)
  end
end
