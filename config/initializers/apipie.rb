Apipie.configure do |config|
  config.app_name                = "EIS Billing System"
  config.app_info                = "Centralized invoice management and payment processing system for Estonian Internet Services"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.action_on_non_validated_keys = :skip
  config.validate = false

  # Authentication for live documentation
  config.authenticate = Proc.new do
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['apipie_login'] && password == ENV['apipie_password']
   end
 end

  # Configuration for static documentation generation
  config.use_cache = Rails.env.production?
  config.cache_dir = Rails.root.join('public', 'apipie-cache')

  # Languages support
  config.default_locale = 'en'
  config.languages = ['en']

  # Layout and styling
  config.layout = 'apipie/apipie'

  # Static files configuration
  config.api_routes = Rails.application.routes
end
