module EverypayLinkGenerator
  extend self

  def create(params:)
    everypay_params = everypay_params(params)

    linker = EverypayV4Wrapper::LinkBuilder.new(key: GlobalVariable::KEY, params: everypay_params)

    linker.build_link
  end

  def everypay_params(params)
    {
      transaction_amount: params[:transaction_amount].to_s,
      order_reference: params[:invoice_number].to_s,
      customer_name: params[:customer_name].to_s, # buyer_name
      customer_email: params[:customer_email].to_s, # buyer_email
      custom_field_1: params.fetch(:custom_field1, ''),
      custom_field_2: params[:custom_field2].to_s,
      invoice_number: params[:invoice_number].to_s,
      linkpay_token: GlobalVariable::LINKPAY_TOKEN
    }
  end
end
