class Dashboards::InvoiceStatusController < ParentController
  before_action :require_user_logged_in!

  def update
    @invoice = Invoice.find(params[:id])
    temporary_unavailable and return unless @invoice.registry?

    resp = @invoice.synchronize(status: params[:status])
    if resp.result?
      @invoice.update(status: params[:status])

      redirect_to dashboard_index_path, status: :see_other, flash: { notice: 'Invoice status updated successfully' }
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = resp.errors['message']
          render turbo_stream: [
            render_turbo_flash
          ]
        end
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
