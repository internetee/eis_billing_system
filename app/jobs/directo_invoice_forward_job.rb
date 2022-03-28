#[#<ActionController::Parameters {"registrar"=>{"id"=>1, "name"=>"Registrar First", "reg_no"=>"90010019", "vat_no"=>"EE101286464", "created_at"=>"2022-03-24T16:38:30.896+02:00", "updated_at"=>"2022-03-24T16:38:30.896+02:00", "creator_str"=>"rake-root db:setup:all", "updator_str"=>"rake-root db:setup:all", "phone"=>nil, "email"=>"registrar@first.tld", "billing_email"=>"registrar@first.tld", "address_country_code"=>"EE", "address_state"=>"Harjumaa", "address_city"=>"Tallinn", "address_street"=>"Tänav 1", "address_zip"=>"1234546", "code"=>"REG1", "website"=>nil, "accounting_customer_code"=>"1234", "reference_no"=>"11", "test_registrar"=>false, "language"=>"EE", "vat_rate"=>nil, "iban"=>nil, "settings"=>{}, "legaldoc_optout"=>false, "legaldoc_optout_comment"=>nil, "email_history"=>nil}, "registrar_summery"=>nil} permitted: false>, #<ActionController::Parameters {"registrar"=>{"id"=>2, "name"=>"OG", "reg_no"=>"12345623", "vat_no"=>"123456789", "created_at"=>"2022-03-24T16:46:07.970+02:00", "updated_at"=>"2022-03-24T16:46:07.970+02:00", "creator_str"=>"1-AdminUser: admin", "updator_str"=>"1-AdminUser: admin", "phone"=>"372.35345345", "email"=>"admin@n-brains.com", "billing_email"=>"oleg.hasjanov@internet.ee", "address_country_code"=>"EE", "address_state"=>"Harjumaa", "address_city"=>"Tallinn", "address_street"=>"Kivila 13", "address_zip"=>"23324", "code"=>"OLEG777", "website"=>"https://n-brains.com", "accounting_customer_code"=>"330099886633322", "reference_no"=>"3233065", "test_registrar"=>false, "language"=>"en", "vat_rate"=>nil, "iban"=>"12345678990", "settings"=>{}, "legaldoc_optout"=>false, "legaldoc_optout_comment"=>"", "email_history"=>nil}, "registrar_summery"=>nil} permitted: false>]


class DirectoInvoiceForwardJob < ApplicationJob
  def perform(invoice_data:, initiator:)
    @initiator = initiator
    @invoice_data = invoice_data
    @client = new_directo_client

    send_receipts
  end

  private

  def new_directo_client
    DirectoApi::Client.new(ENV['directo_invoice_url'], Setting.directo_sales_agent,
                           Setting.directo_receipt_payment_term)
  end

  def send_receipts
    if @initiator == 'auction'
      @client.invoices.add_with_schema(invoice: @invoice_data, schema: 'auction')
    else
      @client.invoices.add_with_schema(invoice: @invoice_data, schema: 'prepayment')
    end

    sync_with_directo
  end

  def sync_with_directo
    Rails.logger.info("[Directo] - attempting to send following XML:\n #{@client.invoices.as_xml}")

    response = @client.invoices.deliver(ssl_verify: false)

    Rails.logger.info("[Directo] - response received:\n #{response.body}")
    Rails.logger.info("[Directo] - initiator:\n #{@initiator}")

    process_directo_response(xml: @client.invoices.as_xml, response: response.body)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def process_directo_response(xml:, response:)
    Rails.logger.info "[Directo] - Responded with body: #{xml}"
    Nokogiri::XML(response).css('Result').each do |res|
      invoice = Invoice.find_by(invoice_number: res.attributes['docid'].value.to_i)
      mark_invoice_as_sent(invoice: invoice)
    end
  end

  def mark_invoice_as_sent(invoice: nil)
    invoice.update(in_directo: true)
  end
end
