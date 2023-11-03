class ParentController < ActionController::Base
  include Pagy::Backend

  include AbstractController::Rendering
  include ActionView::Layouts
  include Authenticate

  layout 'application'
  skip_before_action :verify_authenticity_token

  helper_method :turbo_frame_request?

  def render_turbo_flash
    turbo_stream.update('flash', partial: 'shared/flash')
  end
end
