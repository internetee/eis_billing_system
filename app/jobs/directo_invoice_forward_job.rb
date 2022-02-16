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

    DirectoResponseSender.send_request(response: res.body, xml_data: @client.invoices.as_xml, initiator: @initiator)

    update_number(@client.invoices.as_xml)
  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
    Rails.logger.info('[Directo] Failed to communicate via API')
  end

  def update_number(xml_data)
    Nokogiri::XML(xml_data).css('Result').each do |res|
      invoice_number = res.attributes['docid'].value.to_i

      next unless invoice_number.to_i > Setting.directo_monthly_number_last.to_i

      Setting.directo_monthly_number_last = invoice_number.to_i
    end
  end

  def assign_monthly_numbers
    raise 'Directo Counter is going to be out of period!' if directo_counter_exceedable?(@client.invoices.count)

    min_directo    = Setting.directo_monthly_number_min.presence.try(:to_i)
    directo_number = [Setting.directo_monthly_number_last.presence.try(:to_i),
                      min_directo].compact.max || 0

    @client.invoices.each do |inv|
      directo_number += 1
      inv.number = directo_number
    end
  end
end
