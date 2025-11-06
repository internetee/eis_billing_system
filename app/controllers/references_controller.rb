class ReferencesController < ParentController
  def index
    page = params[:page].presence || 1
    per_page = params[:per_page].presence || 25

    @pagy, @references = pagy(Reference.search(params),
                              page: page,
                              items: per_page,
                              link_extra: 'data-turbo-action="advance"')
  end
end
