class DirectoInvoiceForwardJob < ApplicationJob
  def perform(invoice_data:, initiator:, monthly: false, dry: false)
    @initiator = initiator
    @invoice_data = invoice_data
    @dry = dry
    (@month = Time.zone.now - 1.month) if monthly

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

      if @initiator == 'auction'
        @client.invoices.add_with_schema(invoice: invoice, schema: 'auction')
      else
        @client.invoices.add_with_schema(invoice: invoice, schema: 'prepayment')
      end
    end

    sync_with_directo if @client.invoices.count.positive?
  end

  def send_monthly_invoices
    @invoice_data.each do |data|
      @client = new_directo_client
      send_invoice_for_registrar(data[:summary])
    end
  end

  def send_invoice_for_registrar(summary)
    @client.invoices.add_with_schema(invoice: summary, schema: 'summary') unless summary.nil?

    sync_with_directo if @client.invoices.count.positive?
  end

  def sync_with_directo
    assign_monthly_numbers if @month

    Rails.logger.info("[Directo] - attempting to send following XML:\n #{@client.invoices.as_xml}")
    return if @dry

    res = @client.invoices.deliver(ssl_verify: false)

    Rails.logger.info("[Directo] - response received:\n #{res.body}")
    Rails.logger.info("[Directo] - initiator:\n #{@initiator}")

    registry_response = DirectoResponseSender.send_request(response: res.body, xml_data: @client.invoices.as_xml, initiator: @initiator)

    process_directo_response(@client.invoices.as_xml, res.body)

    Rails.logger.info "Registry response: #{registry_response.body}"
    # update_number(@client.invoices.as_xml)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    NotifierMailer.inform_admin(title: '[Directo] Failed to communicate via API',
                                error_message: '[Directo] Failed to communicate via API').deliver_now
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def process_directo_response(xml, req)
    Rails.logger.info "[Directo] - Responded with body: #{xml}"
    Nokogiri::XML(req).css('Result').each do |res|
      invoice = Invoice.find_by(invoice_number: res.attributes['docid'].value.to_i)
      invoice.update(in_directo: true)
    end
  end

  def mark_invoice_as_sent(invoice: nil, res:, req:)
    if invoice
      directo_record.item = invoice
      invoice.update(in_directo: true)
    end

    directo_record.save!
  end
end
