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

# https://igw-demo.every-pay.com/lp?custom_field_1=prepended&custom_field_2=auction&customer_email=timo.vohmar@eestiinternet.ee&customer_name=mary_%C3%A4nn_o%E2%80%99conne%C5%BE-%C5%A1uslik_testnumber&invoice_number=160022&linkpay_token=k5t5xq&order_reference=160022&transaction_amount=6.00&hmac=2910ac02460da34eeedb1b5e248360a6d4e2d636bf727f2291e235d62ac3505f