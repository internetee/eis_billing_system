require 'openssl'
require 'cgi'

params = {
  'custom_field_1' => '5e03f248-6',
  'custom_field_2' => 'business_registry',
  'customer_email' => '',
  'customer_name' => '',
  'invoice_number' => '160523',
  'linkpay_token' => 'z8bi2wj4gq',
  'order_reference' => '160523',
  'reference_number' => '',
  'transaction_amount' => '20.0'
}

query = params.keys.sort.map { |k| "#{CGI.escape(k)}=#{CGI.escape(params[k])}" }.join('&')
puts "Query with invoice_number: #{query}"

params_without = params.reject { |k,v| k == 'invoice_number' }
query_without = params_without.keys.sort.map { |k| "#{CGI.escape(k)}=#{CGI.escape(params_without[k])}" }.join('&')
puts "Query without invoice_number: #{query_without}"
