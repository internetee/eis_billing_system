class InvoiceInstanceGenerator
  AUCTION_DEPOSIT = 'auction_deposit'.freeze
  REGULAR = 'regular'.freeze

  def self.create(params:)
    description = if params[:reserved_domain_names].present?
                    "Reserved domain names: #{params[:reserved_domain_names].join(', ')}; User unique id: #{params[:custom_field1]}"
                  else
                    params.fetch(:custom_field1, 'reload balance').to_s
                  end

    Invoice.create!(invoice_number: params[:invoice_number].to_s,
                    initiator: params[:custom_field2].to_s,
                    transaction_amount: params[:transaction_amount].to_s,
                    description:,
                    affiliation: params.fetch(:affiliation, REGULAR).to_s == AUCTION_DEPOSIT ? 1 : 0,
                    status: params[:transaction_amount].to_s == '0.0' ? :paid : :unpaid)
  end
end
