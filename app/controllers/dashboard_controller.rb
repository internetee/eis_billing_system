class DashboardController < ParentController
  def index
    page = [params[:page].to_i, 1].max
    @pagy, @invoices = pagy(Invoice.search(params),
                            items: params[:per_page] ||= 25,
                            page:,
                            link_extra: 'data-turbo-action="advance"')

    @min_amount = 0
    @max_amount = 200_000
  end
end
