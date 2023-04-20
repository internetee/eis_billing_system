class InvoiceDetails::PaymentReferencesController < ParentController
  before_action :require_user_logged_in!

  def show
    @payment_reference = Invoice.find(params[:id])&.payment_reference
  end
end
