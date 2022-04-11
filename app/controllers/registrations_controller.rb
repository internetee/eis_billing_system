class RegistrationsController < ParentController
  before_action :require_user_logged_in!

  # instantiates new user
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @new_user = User.new

    if @user.save
    # stores saved user id in a session
      # session[:user_id] = @user.id
      # redirect_to root_path, notice: 'Successfully created account'
      flash[:notice] = 'Successfully created account'

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend('users', partial: "users/user", locals: { user: @user }),
            turbo_stream.update('new_user', partial: "users/form", locals: { user: @new_user, url: sign_up_path })
          ]
        end
      end
    else
      render :new
    end
  end
  private
  def user_params
    # strong parameters
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
