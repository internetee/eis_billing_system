module InvoiceInstanceGenerator
  extend self

  def create(params:)
    Invoice.create!(invoice_number: params[:invoice_number].to_s,
                    initiator: params[:custom_field_2].to_s,
                    transaction_amount: params[:transaction_amount].to_s)
  end
end
