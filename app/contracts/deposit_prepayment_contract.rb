class DepositPrepaymentContract < Dry::Validation::Contract
  ALLOWED_BASE_URL = [
    GlobalVariable::BASE_REGISTRY,
    GlobalVariable::BASE_REGISTRAR,
    GlobalVariable::BASE_AUCTION,
    GlobalVariable::BASE_EEID
  ].freeze

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

  # in dev env using docker and configurable hosts
  # lets say if in docker address of registry is http://registry:3000
  # but in etc/hosts address of registry is https://registry.test
  def development_case
    [
      'https://registry.test',
      'https://registrar_center.test',
      'https://eeid.test',
      'https://auction_center.test',
      'https://auction.test',
    ]
  end
end
