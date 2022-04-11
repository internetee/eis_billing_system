class ParentController < ActionController::Base
  include Pagy::Backend

  include AbstractController::Rendering
  include ActionView::Layouts
  append_view_path "#{Rails.root}/app/views"
  layout 'application.html.erb'
  skip_before_action :verify_authenticity_token

  before_action :set_current_user

  def render_turbo_flash
    turbo_stream.update('flash', partial: 'shared/flash')
  end

  def set_current_user
    # finds user with session data and stores it if present
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def require_user_logged_in!
    # allows only logged in user
    redirect_to sign_in_path, alert: 'You must be signed in', turbolinks: false if Current.user.nil?
  end
end
