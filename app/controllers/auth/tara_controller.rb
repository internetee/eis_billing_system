# rubocop:disable Metrics

module Auth
  class TaraController < ParentController
    allow_unauthenticated

    rescue_from NotAuthorizedError, with: :render_forbidden_error

    def callback
      expires_now && reset_session

      raise NotAuthorizedError unless in_white_list?

      session[:omniauth_hash] = user_hash.delete_if { |key, _| key == 'credentials' }
      @user = User.from_omniauth(user_hash)
      @user.save! && @user.reload

      @app_session = create_app_session

      if @app_session
        log_in @app_session
        set_current_session

        redirect_to root_path, status: :see_other
      else
        flash[:alert] = I18n.t('.incorrect_details')
        render 'dashboard/index', status: :unprocessable_entity
      end
    end

    private

    def in_white_list?
      WhiteCode.find_by(code: user_hash['uid'].slice(2..-1)).present?
    end

    def set_current_session
      Current.user = @user
      flash[:notice] = I18n.t('.success')
    end

    def user_hash
      request.env['omniauth.auth']
    end

    def create_app_session
      @user.app_sessions.create
    end
  end
end