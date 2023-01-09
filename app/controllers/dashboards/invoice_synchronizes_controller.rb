class Dashboards::InvoiceSynchronizesController < ParentController
  def update
    invoice = Invoice.find(params[:id])

    respond_to do |format|
      format.turbo_stream do
        if invoice.synchronize.result?
          flash[:notice] = 'Invoice data was successfully updated'
        else
          flash[:alert] = response.errors[:message]
        end

        render turbo_stream: [render_turbo_flash]
      end
    end
  end
end
