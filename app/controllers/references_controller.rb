class ReferencesController < ParentController
  before_action :require_user_logged_in!

  def index
    @pagy, @references = pagy(Reference.search(params), items: params[:per_page] ||= 25, link_extra: 'data-turbo-action="advance"')
  end
end
