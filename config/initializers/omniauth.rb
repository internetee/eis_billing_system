OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = %i[post]

tara_keys = ENV['tara_keys']
tara_scope = %w[openid idcard mid smartid]
tara_issuer = ENV['tara_issuer']
tara_host = ENV['tara_host']
tara_jwks_uri = ENV['tara_jwks_uri']
tara_identifier = ENV['tara_identifier']
tara_secret = ENV['tara_secret']
tara_redirect_uri = ENV['tara_redirect_uri']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider 'tara', {
    name: 'tara',
    scope: tara_scope,
    state: SecureRandom.hex(10),
    client_signing_alg: :RS256,
    client_jwk_signing_key: tara_keys,
    send_scope_to_token_endpoint: false,
    send_nonce: true,
    issuer: tara_issuer,
    discovery: true,

    client_options: {
      scheme: 'https',
      host: tara_host,
      port: nil,
      authorization_endpoint: '/auth/:provider',
      token_endpoint: '/auth/token',
      userinfo_endpoint: nil, # Not implemented
      jwks_uri: tara_jwks_uri,
      identifier: tara_identifier,
      secret: tara_secret,
      redirect_uri: tara_redirect_uri,
    }
  }
end
