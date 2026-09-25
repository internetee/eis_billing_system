module Montonio
  # Montonio webhooks carry no application authentication - the body is a JWT
  # signed with our store secret key, so verifying that signature (and that the
  # token was issued for our store) is what makes the callback trustworthy.
  class OrderTokenVerifier
    ALGORITHM = 'HS256'.freeze
    LEEWAY_IN_SECONDS = 300 # docs recommend a few minutes of clock tolerance

    attr_reader :token

    def self.call(token)
      new(token).call
    end

    def initialize(token)
      @token = token
    end

    def call
      raise InvalidTokenError, 'Montonio token is missing' if token.blank?
      raise ConfigurationError, 'Montonio secret key is not configured' if Montonio.secret_key.blank?

      payload = decode
      verify_access_key!(payload)

      payload
    end

    private

    def decode
      JWT.decode(token, Montonio.secret_key, true, algorithm: ALGORITHM, leeway: LEEWAY_IN_SECONDS).first
    rescue JWT::DecodeError => e
      raise InvalidTokenError, "Montonio token could not be verified: #{e.message}"
    end

    def verify_access_key!(payload)
      return if payload['accessKey'].present? && payload['accessKey'] == Montonio.access_key

      raise InvalidTokenError, 'Montonio token was issued for a different store'
    end
  end
end
