class InvoiceInstanceGenerator
  AUCTION_DEPOSIT = 'auction_deposit'.freeze
  REGULAR = 'regular'.freeze

  def self.create(params:)
    Invoice.create!(invoice_number: params[:invoice_number].to_s,
                    initiator: params[:custom_field2].to_s,
                    transaction_amount: params[:transaction_amount].to_s,
                    description: params.fetch(:custom_field1, 'reload balance').to_s,
                    affiliation: params.fetch(:affiliation, REGULAR).to_s == AUCTION_DEPOSIT ? 1 : 0)
  end
end
