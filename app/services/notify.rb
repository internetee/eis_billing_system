class Notify < Base
  def self.call(response)
    parsed_response = parse_response(response)
    invoice = Invoice.find_by(invoice_number: parsed_response[:order_reference])

    return false if invoice.nil?

    invoice.update(payment_reference: parsed_response[:payment_reference])

    return logger.info "Invoice not found\n Yout response #{parsed_response}" if invoice.nil?

    url = get_update_payment_url[invoice.initiator.to_sym]

    return logger.info "Not found initiator. Inititor #{invoice.initiator}" if url.nil?

    parsed_response[:invoice_number_collection] = invoice_numbers_from_multi_payment(invoice)

    http = generate_http_request_sender(url: url)
    http.put(url, parsed_response.to_json, generate_headers)
  end

  def self.invoice_numbers_from_multi_payment(invoice)
    return unless invoice.initiator == 'auction'

    numbers = invoice.description.split(' ')
    results = Invoice.where(invoice_number: numbers).pluck(:invoice_number, :payment_reference)
    data = []

    results.each do |r|
      data << { number: r[0], ref: r[1] }
    end

    data
  end

  def self.get_update_payment_url
    {
      registry: ENV['registry_update_payment_url'],
      auction: ENV['auction_update_payment_url'],
      eeid: ENV['eeid_update_payment_url']
    }
  end

  def self.parse_response(response)
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

  def self.logger
    @logger ||= Rails.logger
  end
end
