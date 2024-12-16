class InvoicesController < ParentController
  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update(invoice_params)
    redirect_to invoice_creators_path, notice: 'Invoice was successfully updated.', status: :see_other
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  private

  def invoice_params
    params.require(:invoice).permit(:invoice_number, :affiliation, :initiator, :transaction_amount, :description)
  end
end
