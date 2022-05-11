class EverypayLinkGenerator
  attr_reader :params

  def initialize(params:)
    @params = params
  end

  def self.create(params:)
    fetcher = new(params: params)
    everypay_params = fetcher.linkpay_params(params)

    fetcher.build_link(everypay_params.to_query)
  end

  def linkpay_params(params)
    { 'transaction_amount' => params[:transaction_amount].to_s,
      'order_reference' => params[:invoice_number].to_s,
      'customer_name' => params[:customer_name].to_s.parameterize(separator: '%20', preserve_case: true),
      'customer_email' => params[:customer_email].to_s,
      'custom_field_1' => params.fetch(:custom_field1, '').to_s.parameterize(separator: '%20', preserve_case: true),
      'custom_field_2' => params[:custom_field2].to_s.parameterize(separator: '%20', preserve_case: true),
      'linkpay_token' => GlobalVariable::LINKPAY_TOKEN,
      'invoice_number' => params[:invoice_number].to_s }
  end

  def build_link(params)
    data = CGI.unescape(params)
    hmac = OpenSSL::HMAC.hexdigest('sha256', GlobalVariable::KEY, data)

    "https://igw-demo.every-pay.com/lp?#{CGI.unescape(data)}&hmac=#{hmac}"
  end
end
