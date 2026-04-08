OpenIDConnect.logger = Rails.logger
OpenIDConnect.debug!

OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = %i[post]

signing_keys = ENV['tara_keys']
scope = ENV['tara_scope']
issuer = ENV['tara_issuer']
host = ENV['tara_host']
port = ENV['tara_port']
jwks_uri = ENV['tara_jwks_uri']
identifier = ENV['tara_identifier']
secret = ENV['tara_secret']
redirect_uri = ENV['tara_redirect_uri']
discovery = ENV['tara_discovery']
authorization_endpoint = ENV['tara_authorization_endpoint']
token_endpoint = ENV['tara_token_endpoint']
scheme = ENV['tara_scheme']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider 'tara', {
    name: 'tara',
    scope: scope || ['openid'],
    state: SecureRandom.hex(10),
    client_signing_alg: :RS256,
    client_jwk_signing_key: signing_keys,
    send_scope_to_token_endpoint: false,
    send_nonce: true,
    issuer: issuer,
    discovery: discovery,

    client_options: {
      scheme: scheme || 'https',
      host: host,
      port: port,
      authorization_endpoint: authorization_endpoint || '/oidc/authorize',
      token_endpoint: token_endpoint || '/oidc/token',
      userinfo_endpoint: nil, # Not implemented
      jwks_uri: jwks_uri || '/oidc/jwks',
      identifier: identifier,
      secret: secret,
      redirect_uri: redirect_uri,
    }
  }
end
