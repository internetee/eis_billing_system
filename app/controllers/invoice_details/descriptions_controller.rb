class InvoiceDetails::DescriptionsController < ParentController
  def show
    @description = Invoice.find(params[:id])&.description
  end
end
