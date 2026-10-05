# Montonio payment links (https://docs.montonio.com/api/stargate/guides/payment-links).
#
# Used only for auction invoices, because - unlike EveryPay LinkPay - Montonio
# lets us set the moment the link stops accepting payments. Everything else
# keeps using EveryPay.
module Montonio
  class Error < StandardError; end

  # Montonio keys are not configured in this environment.
  class ConfigurationError < Error; end

  # Montonio answered with a non 2xx status or an unusable body.
  class RequestError < Error; end

  # Webhook token could not be verified.
  class InvalidTokenError < Error; end

  # Webhook refers to a payment link we do not know about.
  class UnknownPaymentLinkError < Error; end

  PROVIDER = 'montonio'.freeze
  CURRENCY = 'EUR'.freeze

  module_function

  def base_url
    GlobalVariable::MONTONIO_BASE
  end

  def access_key
    GlobalVariable::MONTONIO_ACCESS_KEY
  end

  def secret_key
    GlobalVariable::MONTONIO_SECRET_KEY
  end

  def notification_url
    GlobalVariable::MONTONIO_NOTIFICATION_URL
  end

  def configured?
    access_key.present? && secret_key.present?
  end
end
