class EverypayLinkGenerator
  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def self.create(params:)
    fetcher = new(params: params)
    everypay_params = fetcher.linkpay_params(params)

    res = HttpBuildQuery.create everypay_params
    res.gsub!('+', '%20')

    # fetcher.build_link(everypay_params.to_query)
    fetcher.build_link(res)
  end

  def linkpay_params(params)
    { 'transaction_amount' => params[:transaction_amount].to_s,
      'order_reference' => params[:invoice_number].to_s,
      'customer_name' => params[:customer_name].to_s,
      'customer_email' => params[:customer_email].to_s,
      'custom_field_1' => params.fetch(:custom_field1, '').to_s,
      'custom_field_2' => params[:custom_field2].to_s,
      'linkpay_token' => GlobalVariable::LINKPAY_TOKEN,
      'invoice_number' => params[:invoice_number].to_s }
  end

  def build_link(params)
    hmac = OpenSSL::HMAC.hexdigest('sha256', GlobalVariable::KEY, params)

    "https://igw-demo.every-pay.com/lp?#{params}&hmac=#{hmac}"
  end
end
