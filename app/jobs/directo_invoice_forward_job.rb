class DirectoInvoiceForwardJob < ApplicationJob
  def perform(invoice_data:, initiator:, monthly: false, dry: false)
    @initiator = initiator
    @invoice_data = invoice_data
    @dry = dry
    (@month = Time.zone.now - 1.month) if monthly

    @client = new_directo_client
    monthly ? send_monthly_invoices : send_receipts
  end

  private

  def new_directo_client
    DirectoApi::Client.new(ENV['directo_invoice_url'], Setting.directo_sales_agent,
                           Setting.directo_receipt_payment_term)
  end

  def send_receipts
    @invoice_data.each do |invoice|
      if @initiator == 'auction'
        @client.invoices.add_with_schema(invoice: invoice, schema: 'auction')
      else
        @client.invoices.add_with_schema(invoice: invoice, schema: 'prepayment')
      end
    end

    sync_with_directo
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

    Rails.logger.info "Registry response: #{registry_response.body}"
    # update_number(@client.invoices.as_xml)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info('[Directo] Failed to communicate via API')
  end
end
