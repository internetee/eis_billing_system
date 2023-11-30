class InvoiceDetails::LinkpayInformationsController < ParentController
  def show
    @info = Invoice.find(params[:id])&.linkpay_info
  end
end
