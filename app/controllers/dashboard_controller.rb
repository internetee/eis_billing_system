class DashboardController < ParentController
  before_action :require_user_logged_in!

  def index
    # @invoices = Invoice.search(params)
    @pagy, @invoices = pagy(Invoice.search(params),
                            items: params[:per_page] ||= 20,
                            link_extra: 'data-turbo-action="advance"')
  end

  def search
    @invoices = Invoice.search(params)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('invoices', partial: "dashboard/invoices", locals: { invoices: @invoices })
        ]
      end
    end
  end
end
