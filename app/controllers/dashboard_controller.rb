class DashboardController < ParentController
  before_action :require_user_logged_in!

  def index
    @pagy, @invoices = pagy(Invoice.search(params),
                            items: params[:per_page] ||= 25,
                            link_extra: 'data-turbo-action="advance"')

    @min_amount = 1
    @max_amount = 200_000
  end

  # def search
  #   @invoices = Invoice.search(params)

  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: [
  #         turbo_stream.update('invoices', partial: 'dashboard/invoices',
  #                                         locals: { invoices: @invoices }),
  #       ]
  #     end
  #   end
  # end

  def description
    @description = Invoice.find(params[:invoice_id]).description
  end
end
