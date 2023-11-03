class InvoiceDetails::PaymentReferencesController < ParentController
  def show
    @payment_reference = Invoice.find(params[:id])&.payment_reference
  end
end
