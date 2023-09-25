module Authenticate
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    before_action :need_to_login, unless: :logged_in?

    helper_method :logged_in?
    helper_method :current_user
  end

  class_methods do
    def skip_authentication(**options)
      skip_before_action :authenticate, options
      skip_before_action :need_to_login, options
    end

    def allow_unauthenticated(**options)
      skip_before_action :need_to_login, options
    end
  end

  protected

  def log_in(app_session, remember_me: false)
    if remember_me
      cookies.encrypted.permanent[:app_session] = {
        value: app_session.to_h
      }
    else
      cookies.signed[:app_session] = {
        value: app_session.to_h,
        expires: 1.day
      }
    end
  end

  def logout
    Current&.app_session&.destroy
  end

  def logged_in?
    Current.user.present?
  end

  def current_user
    Current.user
  end

  private

  def need_to_login
    flash[:notice] = t('login_required')
    render 'sessions/new', status: :unauthorized
  end

  def authenticate
    cookie = cookies.encrypted[:app_session]&.with_indifferent_access
    cookie = cookies.signed[:app_session]&.with_indifferent_access if cookie.nil?

    return nil if cookie.nil?

    user = User.find(cookie[:user_id])
    app_session = user&.authenticate_session_token(cookie[:app_session], cookie[:token])

    Current.user = app_session&.user
    Current.app_session = app_session
  rescue NoMatchingPatternError, ActiveRecord::RecordNotFound
    Current.user = nil
    Current.app_session = nil
  end

  def render_forbidden_error
    flash[:alert] = I18n.t('.access_denied')
    render 'errors/403', status: :forbidden
  end
end

class NotAuthorizedError < StandardError
end

