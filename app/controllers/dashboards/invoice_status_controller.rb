class Dashboards::InvoiceStatusController < ParentController
  before_action :require_user_logged_in!

  def update
    @invoice = Invoice.find(params[:id])
    temporary_unavailable and return unless @invoice.registry?

    if @invoice.update(status: params[:status]) && @invoice.synchronize.result?
      redirect_to dashboard_index_path, status: :see_other, flash: { notice: 'Invoice status updated successfully' }
    else
      flash.now[:alert] = @invoice.errors.full_messages
      render 'dashboard/index', status: :unprocessable_entity
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
