module Notify
  extend self

  def call(response)
    parsed_response = parse_response(response)

    Rails.logger.info "+++++++++ parsed response"
    Rails.logger.info parsed_response

    invoice = Invoice.find_by(invoice_number: parsed_response[:order_reference],
                              transaction_amount: parsed_response[:standing_amount])

    return false if invoice.nil?

    invoice.update(payment_reference: parsed_response[:payment_reference])

    logger.info "Invoice not found\n Yout response #{parsed_response}" if invoice.nil?

    url = update_payment_url(initiator: invoice.initiator)

    logger.info "Not found initiator. Inititor #{invoice.initiator}" if url.nil?

    base_request(params: parsed_response, url: url)
  end

  def base_request(params:, url:)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    unless Rails.env.development?
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    http.put(url, params.to_json, headers)
  end

  def update_payment_url(initiator:)
    if initiator == 'registry'
      return ENV['registry_update_payment_url_dev'] if Rails.env.development?

      ENV['registry_update_payment_url_staging']
    elsif initiator == 'auction'
      ENV['auction_update_payment_url']
    end
  end

  def parse_response(response)
    {
      account_name: response['account_name'],
      order_reference: response['order_reference'],
      email: response['email'],
      customer_ip: response['customer_ip'],
      customer_url: response['customer_url'],
      payment_created_at: response['payment_created_at'],
      initial_amount: response['initial_amount'],
      standing_amount: response['standing_amount'],
      payment_reference: response['payment_reference'],
      payment_link: response['payment_link'],
      api_username: response['api_username'],
      warnings: response['warnings'],
      stan: response['stan'],
      fraud_score: response['fraud_score'],
      payment_state: response['payment_state'],
      payment_method: response['payment_method'],
      ob_details: response['ob_details'],
      creditor_iban: response['creditor_iban'],
      ob_payment_reference: response['ob_payment_reference'],
      ob_payment_state: response['ob_payment_state'],
      transaction_time: response['transaction_time']
    }
  end

  def generate_token
    JWT.encode(payload, ENV['secret_word'])
  end

  def payload
    { data: GlobalVariable::SECRET_WORD }
  end

  def headers 
    {
    'Authorization' => "Bearer #{generate_token}",
    'Content-Type' => 'application/json',
    }
  end

  def logger
    @logger ||= Rails.logger
  end
end
