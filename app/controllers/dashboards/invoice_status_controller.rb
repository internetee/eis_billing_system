class Dashboards::InvoiceStatusController < ParentController
  before_action :require_user_logged_in!

  def update
    @invoice = Invoice.find(params[:id])

    if @invoice.update(status: params[:status]) && @invoice.synchronize.result?
      redirect_to dashboard_index_path, status: :see_other, flash: { notice: 'Invoice status updated successfully' }
    else
      flash.now[:alert] = @invoice.errors.full_messages
      render 'dashboard/index', status: :unprocessable_entity
    end
  end
end
