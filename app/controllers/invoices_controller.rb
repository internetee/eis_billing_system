class InvoicesController < ParentController
  def update
    @invoice = Invoice.find(params[:id])
    @invoice.update(invoice_params)

    flash.now[:notice] = 'Invoice was successfully updated.'
    render turbo_stream: turbo_stream.replace('flash', partial: 'shared/flash')
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def pdf
    generator = InvoicePdfGenerator.new(Invoice.find(params[:id]))

    send_data generator.as_pdf,
              filename: generator.filename,
              type: 'application/pdf',
              disposition: 'attachment'
  end

  private

  def invoice_params
    params.require(:invoice).permit(:invoice_number, :affiliation, :initiator, :transaction_amount, :description)
  end
end
