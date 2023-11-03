class DashboardController < ParentController
  def index
    @pagy, @invoices = pagy(Invoice.search(params),
                            items: params[:per_page] ||= 25,
                            link_extra: 'data-turbo-action="advance"')

    @min_amount = 0
    @max_amount = 200_000
  end
end
