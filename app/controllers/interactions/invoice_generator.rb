module InvoiceGenerator
  extend self

  def run(params)
    InvoiceInstanceGenerator.create(params: params)
    EverypayLinkGenerator.create(params: params)
  end
end
