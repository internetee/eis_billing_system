module EverypayLinkGenerator
  extend self

  def create(invoice:)
    everypay_params = everypay_params(invoice)
    linker = EverypayV4Wrapper::LinkBuilder.new(key: GlobalVariable::KEY, params: everypay_params)
    link = linker.build_link

    invoice.payment_link = link
    invoice.save

    link
  end

  def everypay_params(invoice)
    {
      transaction_amount: invoice.transaction_amount,
      order_reference: invoice.invoice_number,
      customer_name: invoice.buyer_name,
      customer_email: invoice.buyer_email,
      custom_field_1: invoice.description,
      invoice_number: invoice.invoice_number,
      linkpay_token: GlobalVariable::LINKPAY_TOKEN
    }
  end
end
