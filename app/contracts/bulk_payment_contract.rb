class BulkPaymentContract < Dry::Validation::Contract
  include BaseContract

  params do
    required(:custom_field2).filled(:string)
    required(:customer_url).filled(:string)
    required(:description).filled(:string)
    required(:transaction_amount).filled(:string)
  end

  rule(:customer_url) do
    customer_url = "#{URI.parse(value).scheme}://#{URI.parse(value).host}"
    urls = Rails.env.development? ? development_case : ALLOWED_BASE_URL
    result = urls.any? { |url| url.include? customer_url }

    key.failure(I18n.t('api_errors.customer_url_error')) unless result
  end
end
