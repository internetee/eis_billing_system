class DashboardController < ParentController
  def index
    page = params[:page].presence&.to_i || 1
    page = [page, 1].max
    per_page = params[:per_page].presence || 25

    @pagy, @invoices = pagy(Invoice.search(params),
                            page: page,
                            items: per_page,
                            link_extra: 'data-turbo-action="advance"')

    @min_amount = 0
    @max_amount = 200_000
  end
end
