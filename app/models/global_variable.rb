class GlobalVariable
  SECRET_WORD = ENV['secret_access_word']
  LINKPAY_PREFIX = ENV['linkpay_prefix']
  LINKPAY_TOKEN = ENV['linkpay_token']

  API_USERNAME = ENV['api_username']
  KEY = ENV['everypay_key']
  BASE_ENDPOINT = 'https://igw-demo.every-pay.com/api/v4'.freeze
  ONEOFF_ENDPOINT = '/payments/oneoff'.freeze
  ACCOUNT_NAME = ENV['account_name']

  INITIATOR = 'billing'.freeze
  BILLING_SECRET = ENV['billing_secret']
  TIMEOUT_IN_SECONDS = ENV['timeout_is_sec'].to_i
end
