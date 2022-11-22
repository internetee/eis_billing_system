Apipie.configure do |config|
  config.app_name                = "EisBillingSystem"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.action_on_non_validated_keys = :skip
  config.validate = false

  config.authenticate = Proc.new do
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['apipie_login'] && password == ENV['apipie_password']
   end
 end
end
