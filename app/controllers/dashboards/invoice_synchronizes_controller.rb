class Dashboards::InvoiceSynchronizesController < ParentController
  def update
    @invoice = Invoice.find(params[:id])
    temporary_unavailable and return unless @invoice.registry?

    respond_to do |format|
      format.turbo_stream do
        if @invoice.synchronize.result?
          flash[:notice] = 'Invoice data was successfully updated'
        else
          flash[:alert] = response.errors[:message]
        end

        render turbo_stream: [render_turbo_flash]
      end
    end
  end

  private

  def temporary_unavailable
    respond_to do |format|
      flash[:alert] = 'Synchronization for this service not working at the moment!'
      format.turbo_stream { render turbo_stream: [render_turbo_flash] }
    end
  end
end
