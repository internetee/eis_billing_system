class OneoffParamsContract < Dry::Validation::Contract
  include BaseContract

  params do
    required(:invoice_number).filled(:string)
    required(:customer_url).filled(:string)
    # required(:reference_number).filled(:string)
  end

  rule(:customer_url) do
    customer_url = "#{URI.parse(value).scheme}://#{URI.parse(value).host}"

    # urls = Rails.env.development? ? development_case : ALLOWED_BASE_URL
    result = ALLOWED_BASE_URL.any? { |url| url.include? customer_url }

    key.failure(I18n.t('api_errors.customer_url_error')) unless result
  end
end
