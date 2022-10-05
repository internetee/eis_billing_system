class DirectoInvoiceForwardJob < ApplicationJob
  def perform(invoice_data:, initiator:, monthly: false, dry: false)
    @initiator = initiator
    @invoice_data = invoice_data
    @dry = dry
    @monthly = monthly

    @client = new_directo_client
    monthly ? send_monthly_invoices : send_receipts
  rescue StandardError => e
    NotifierMailer.inform_admin(title: 'Directo error occur',
                                error_message: e.message).deliver_now
  end

  private

  def new_directo_client
    DirectoApi::Client.new(ENV['directo_invoice_url'], Setting.directo_sales_agent,
                           Setting.directo_receipt_payment_term)
  end

  def send_receipts
    @invoice_data.each do |invoice|
      invoice = JSON.parse(invoice.to_json)

      next unless Invoice.exists?(invoice_number: invoice['number'])

      parsed = JSON.parse(@client.invoices.to_json)
      next if parsed['invoices'].any? { |i| i['number'] == invoice['number'] }

      if @initiator == 'auction'
        @client.invoices.add_with_schema(invoice: invoice, schema: 'auction')
      else
        @client.invoices.add_with_schema(invoice: invoice, schema: 'prepayment')
      end
    end

    sync_with_directo if @client.invoices.count.positive?
  end

  def send_monthly_invoices
    @invoice_data.each do |invoice|
      invoice = JSON.parse(invoice.to_json)
      @client.invoices.add_with_schema(invoice: invoice, schema: 'summary')
    end
    sync_with_directo if @client.invoices.count.positive?
  end

  def sync_with_directo
    Rails.logger.info("[Directo] - attempting to send following XML:\n #{@client.invoices.as_xml}")
    return if @dry

    res = @client.invoices.deliver(ssl_verify: false)

    Rails.logger.info("[Directo] - response received:\n #{res.body}")
    Rails.logger.info("[Directo] - initiator:\n #{@initiator}")

    initiator_response = DirectoResponseSender.send_request(response: res.body,
                                                            xml_data: @client.invoices.as_xml,
                                                            initiator: @initiator)

    process_directo_response(@client.invoices.as_xml, res.body)

    Rails.logger.info "Initiator response: #{initiator_response}"
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    NotifierMailer.inform_admin(title: '[Directo] Failed to communicate via API',
                                error_message: '[Directo] Failed to communicate via API')
                  .deliver_now
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def process_directo_response(xml, req)
    Rails.logger.info "[Directo] - Responded with body: #{xml}"
    Nokogiri::XML(req).css('Result').each do |res|
      invoice_number = res.attributes['docid'].value.to_i
      invoice = Invoice.find_by(invoice_number: invoice_number)
      invoice&.update(in_directo: true, directo_data: xml)
    end
  end
end
