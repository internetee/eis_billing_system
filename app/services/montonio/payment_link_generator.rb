module Montonio
  # Creates a Montonio payment link:
  # POST {base}/payment-links with a body of {"data": "<HS256 JWT signed with the store secret key>"}
  #
  # Unlike EveryPay LinkPay, the link carries an `expiresAt` - after that moment
  # Montonio refuses to accept orders for it.
  class PaymentLinkGenerator
    include Request

    PATH = '/payment-links'.freeze
    TOKEN_TTL_IN_SECONDS = 600 # validity of the JWT itself, unrelated to the link expiry
    DEFAULT_LOCALE = 'en'.freeze
    SUPPORTED_LOCALES = %w[de en et fi lt lv pl ru].freeze
    DESCRIPTION_LIMIT = 100

    Link = Struct.new(:uuid, :url, :short_url, :expires_at, keyword_init: true)

    attr_reader :invoice_number, :amount, :description, :expires_at, :locale, :return_url

    def self.call(invoice_number:, amount:, expires_at:, description: nil, locale: nil, return_url: nil)
      new(invoice_number: invoice_number,
          amount: amount,
          expires_at: expires_at,
          description: description,
          locale: locale,
          return_url: return_url).call
    end

    def initialize(invoice_number:, amount:, expires_at:, description: nil, locale: nil, return_url: nil)
      @invoice_number = invoice_number
      @amount = amount
      @description = description
      @expires_at = expires_at
      @locale = normalize_locale(locale)
      @return_url = return_url
    end

    def call
      raise ConfigurationError, 'Montonio access key and secret key are not configured' unless Montonio.configured?
      raise RequestError, 'Montonio payment link requires an expiry' if expires_at.blank?

      build_link(perform_request)
    end

    def payload
      {
        accessKey: Montonio.access_key,
        description: full_description,
        currency: CURRENCY,
        amount: normalized_amount,
        locale: locale,
        askAdditionalInfo: false,
        expiresAt: expires_at,
        notificationUrl: Montonio.notification_url.presence,
        returnUrl: return_url.presence,
        exp: Time.zone.now.to_i + TOKEN_TTL_IN_SECONDS
      }.compact
    end

    def token
      JWT.encode(payload, Montonio.secret_key, 'HS256')
    end

    private

    def perform_request
      response = post_raw(direction: 'montonio', path: url, params: { data: token })
      unless response.success?
        raise RequestError, "Montonio responded with status #{response.status}: #{response.body}"
      end

      parse_body(response.body)
    end

    def build_link(body)
      raise RequestError, "Montonio response has no payment link url: #{body}" if body['url'].blank?

      Link.new(uuid: body['uuid'],
               url: body['url'],
               short_url: body['shortUrl'],
               expires_at: expires_at)
    end

    def parse_body(body)
      JSON.parse(body.to_s)
    rescue JSON::ParserError => e
      raise RequestError, "Montonio response is not valid JSON: #{e.message}"
    end

    def url
      "#{Montonio.base_url}#{PATH}"
    end

    # Shown on the Montonio payment page and relayed to the bank as the payment
    # description, so it has to carry the invoice number.
    def full_description
      [invoice_number.to_s.presence, description.to_s.presence].compact.join(' ')[0, DESCRIPTION_LIMIT]
    end

    def normalized_amount
      BigDecimal(amount.to_s).round(2).to_f
    end

    def normalize_locale(value)
      locale = value.to_s.strip.downcase
      SUPPORTED_LOCALES.include?(locale) ? locale : DEFAULT_LOCALE
    end
  end
end
