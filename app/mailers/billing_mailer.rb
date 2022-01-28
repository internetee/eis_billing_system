class BillingMailer < ApplicationMailer
  # def invoice_email(invoice:, recipient:, paid: false)
  # def invoice_email(invoice:)
  #   @invoice = invoice
  #   @link = generate_link
  #   mail(to: @invoice.buyer_email, subject: 'Invoice generated')
  # end

  # private

  # def generate_link
  #   @everypay_params = {
  #     transaction_amount: @invoice.transaction_amount,
  #     order_reference: @invoice.invoice_number,
  #     customer_name: @invoice.buyer_name,
  #     customer_email: @invoice.buyer_email,
  #     custom_field_1: @invoice.description,
  #     invoice_number: @invoice.invoice_number,
  #     linkpay_token: GlobalVariable::LINKPAY_TOKEN
  #   }

  #   linker = EverypayV4Wrapper::LinkBuilder.new(key: GlobalVariable::KEY, params: @everypay_params)
  #   linker.build_link
  # end
end
