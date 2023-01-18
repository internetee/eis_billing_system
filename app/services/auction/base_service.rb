module Auction
  module BaseService
    include ApplicationService

    AUCTION_DEPOSIT = 'auction_deposit'.freeze

    def oneoff_link(bulk: false)
      invoice_number = InvoiceNumberService.call(invoice_auction_deposit: true)
      invoice_params = invoice_params(params, invoice_number)

      InvoiceInstanceGenerator.create(params: invoice_params)
      response = Oneoff.call(invoice_number: invoice_number.to_s,
                             customer_url: params[:customer_url],
                             reference_number: params[:reference_number],
                             bulk: bulk,
                             bulk_invoices: params[:description].to_s.split(' '))
      response.result? ? struct_response(response.instance) : parse_validation_errors(response)
    end

    def invoice_params(params, invoice_number)
      {
        invoice_number: invoice_number,
        custom_field2: params[:custom_field2].to_s,
        transaction_amount: params[:transaction_amount].to_s,
        custom_field1: params[:description].to_s,
        affiliation: params[:affiliation].to_s
      }
    end
  end
end
