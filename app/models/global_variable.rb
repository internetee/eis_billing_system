class GlobalVariable
  SECRET_WORD = ENV['secret_access_word']
  LINKPAY_PREFIX = ENV['linkpay_prefix']
  LINKPAY_TOKEN = ENV['linkpay_token']

  API_USERNAME = ENV['api_username']
  KEY = ENV['everypay_key']
  BASE_ENDPOINT = ENV['everypay_base'] || 'https://igw-demo.every-pay.com/api/v4'
  ONEOFF_ENDPOINT = '/payments/oneoff'.freeze
  ACCOUNT_NAME = ENV['account_name']

  INITIATOR = 'billing'.freeze
  BILLING_SECRET = ENV['billing_secret']
  TIMEOUT_IN_SECONDS = ENV['timeout_is_sec'].to_i

  BASE_REGISTRY = ENV['base_registry'] || 'http://registry:300'
  BASE_REGISTRAR = ENV['base_registrar'] || 'http://registrar_center:300'
  BASE_AUCTION = ENV['base_auction'] || 'http://auction_center:300'
  BASE_EEID = ENV['base_eeid'] || 'http://eeid:300'
end
