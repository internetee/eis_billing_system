class InvoiceDetails::DescriptionsController < ParentController
  before_action :require_user_logged_in!

  def show
    @description = Invoice.find(params[:id])&.description
  end
end
