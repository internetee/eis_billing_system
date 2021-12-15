# frozen_string_literal: true

class DirectoInvoiceForwardJob < ApplicationJob
  def perform
    @client = init_directo_client
    @currency = 'EUR'

    invoice = OpenStruct.new(status: 'paid', in_directo: false)

    @client.invoices.add_with_schema(schema: 'auction',
                                     # invoice: invoice.as_directo_json)
                                     invoice: directo_invoce)
    logger.info @client.invoices.as_xml
    @client.invoices.deliver(ssl_verify: false)

  rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL,
    Errno::ECONNRESET, EOFError, Net::HTTPBadResponse,
    Net::HTTPHeaderSyntaxError, Net::ProtocolError
    logger.info('Network exception when connecting to Directo')
  end

  def init_directo_client
    api_url = 'http://directo.test'
    sales_agent = 'AUCTION'
    payment_terms = directo_default_payment_terms_description

    DirectoApi::Client.new(api_url, sales_agent, payment_terms)
  end

  def directo_default_payment_terms_description
    <<~TEXT.squish
Default payment term for creating invoices for Directo. Defaults to net10
    TEXT
  end

  def directo_customer
    OpenStruct.new(
      vat_number: '123',
      customer_code: '321',

    )
  end

  def directo_invoce
    {"id"=>89, "result_id"=>229, "user_id"=>19, "billing_profile_id"=>24, "issue_date"=>"2021-09-28", "due_date"=>"2021-10-05", "created_at"=>"2021-09-28T23:02:14.252+03:00", "updated_at"=>"2021-11-09T20:45:09.629+02:00", "cents"=>500, "paid_at"=>"2021-11-09T20:45:06.000+02:00", "status"=>"paid", "number"=>89, "uuid"=>"bdc08487-6551-46e3-b71c-9b3cec8c1d65", "vat_rate"=>"0.2", "paid_amount"=>"6.0", "updated_by"=>nil, "notes"=>nil, "paid_with_payment_order_id"=>129, "recipient"=>"test dinar", "vat_code"=>"123456", "legal_entity"=>nil, "street"=>"qwe", "city"=>"rty", "state"=>nil, "postal_code"=>"000000", "alpha_two_country_code"=>"EE", "in_directo"=>false, "transaction_date"=>"2021-11-09", "language"=>"ENG", "currency"=>"MXN", "total_wo_vat"=>0.5e1, "vat_amount"=>0.1e1, "invoice_lines"=>[{"product_id"=>"OKSJON", "description"=>"autofd1.ee", "quantity"=>1, "unit"=>1, "price"=>"5.00"}], "customer"=>{"name"=>"test dinar", "destination"=>"EE", "vat_reg_no"=>"123456", "code"=>"8500221"}}
  end
end

# Setting.find_by(code: 'auction_currency').retrieve => "MXN"
# Setting.find_by(code: 'directo_api_url').retrieve => "https://directo8.gate.ee/ocra_eesti_interneti_sa/transport/xmlcore.asp"
# Setting.find_by(code: 'directo_sales_agent').retrieve => "Silver"
#  payment_terms = Setting.find_by(
#       code: 'directo_default_payment_terms'
#     ).retrieve => "R"

# {"id"=>89, "result_id"=>229, "user_id"=>19, "billing_profile_id"=>24, "issue_date"=>"2021-09-28", "due_date"=>"2021-10-05", "created_at"=>"2021-09-28T23:02:14.252+03:00", "updated_at"=>"2021-11-09T20:45:09.629+02:00", "cents"=>500, "paid_at"=>"2021-11-09T20:45:06.000+02:00", "status"=>"paid", "number"=>89, "uuid"=>"bdc08487-6551-46e3-b71c-9b3cec8c1d65", "vat_rate"=>"0.2", "paid_amount"=>"6.0", "updated_by"=>nil, "notes"=>nil, "paid_with_payment_order_id"=>129, "recipient"=>"test dinar", "vat_code"=>"123456", "legal_entity"=>nil, "street"=>"qwe", "city"=>"rty", "state"=>nil, "postal_code"=>"000000", "alpha_two_country_code"=>"EE", "in_directo"=>false, "transaction_date"=>"2021-11-09", "language"=>"ENG", "currency"=>"MXN", "total_wo_vat"=>0.5e1, "vat_amount"=>0.1e1, "invoice_lines"=>[{"product_id"=>"OKSJON", "description"=>"autofd1.ee", "quantity"=>1, "unit"=>1, "price"=>"5.00"}], "customer"=>{"name"=>"test dinar", "destination"=>"EE", "vat_reg_no"=>"123456", "code"=>"8500221"}}

# => #<Invoice id: 94, result_id: 307, user_id: 19, billing_profile_id: 24, issue_date: "2021-11-19", due_date: "2021-11-26", created_at: "2021-11-19 14:39:09.708082000 +0200", updated_at: "2021-11-19 14:39:09.708082000 +0200", cents: 500, paid_at: nil, status: "issued", number: 94, uuid: "f8c6ad92-5a25-49ec-b608-b113341b969f", vat_rate: nil, paid_amount: nil, updated_by: nil, notes: nil, paid_with_payment_order_id: nil, recipient: "test dinar", vat_code: "123456", legal_entity: nil, street: "qwe", city: "rty", state: nil, postal_code: "000000", alpha_two_country_code: "EE", in_directo: false>

# auction_currency:
#   code: auction_currency
#   description: |
#     Currency in which all invoices and offers are to be made. Allowed values are
#     EUR, USD, CAD, AUD, GBP, PLN, SEK. Default is: EUR
#   value: EUR
#   value_format: string

# def as_directo_json
#   invoice = ActiveSupport::JSON.decode(ActiveSupport::JSON.encode(self))
#   invoice = compose_invoice_meta(invoice)
#   invoice['invoice_lines'] = compose_directo_product
#   invoice['customer'] = compose_directo_customer
#
#   invoice
# end
#
# directo_integration_enabled:
#   code: 'directo_integration_enabled'
#   description: |
#     Enables or disables Directo Integration. Allowed values true / false. Defaults to false.
#   value: 'true'
#   value_format: boolean
#
# directo_api_url:
#   code: 'directo_api_url'
#   description: |
#     API URL for Directo backend
#   value: 'http://directo.test'
#   value_format: string
#
# directo_sales_agent:
#   code: 'directo_sales_agent'
#   description: |
#     Directo SalesAgent value. Retrieve it from Directo.
#   value: 'AUCTION'
#   value_format: string
#
# directo_default_payment_terms:
#   code: 'directo_default_payment_terms'
#   description: |
#     Default payment term for creating invoices for Directo. Defaults to R
#   value: 'R'
#   value_format: string