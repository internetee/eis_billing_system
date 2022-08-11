class UsersController < ParentController
  before_action :require_user_logged_in!

  before_action :set_admin, only: %i[edit update destroy]

  def index
    @users = User.all

    @new_user = User.new
  end

  def new; end

  def edit
    return if @user != Current.user
  end

  def update
    respond_to do |format|
      if Current.user.update(strong_params)
        flash.now[:notice] = 'Admin user was updated'
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.replace(Current.user,
                                 partial: 'users/user',
                                 locals: { user: Current.user }),
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = 'Something went wrong!'
          render turbo_stream: [
            render_turbo_flash,
          ]
        end
      end
    end
  end

  def destroy
    title = @user.email
    respond_to do |format|
      if @user.destroy
        flash.now[:alert] = "#{title} was deleted"
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove(@user),
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = 'Something went wrong!'
          render turbo_stream: []
        end
      end
    end
  end

  def search
    redirect_to users_path and return unless params[:title_search].present?

    @search_param = params[:title_search].to_s.downcase
    @users = User.search_by_email(@search_param).with_pg_search_highlight

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('users', partial: 'users/users', locals: { users: @users }),
        ]
      end
    end
  end

  private

  def strong_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def set_admin
    @user = User.find(params[:id])
  end
end
