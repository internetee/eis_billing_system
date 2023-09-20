class CaptureContract < Dry::Validation::Contract
  # include BaseContract

  params do
    required(:amount).filled(:decimal)
    required(:payment_reference).filled(:string)
  end

  rule(:payment_reference) do
    key.failure(I18n.t('api_errors.invalid_payment_reference')) unless Invoice.exists?(payment_reference: value)
  end
end
