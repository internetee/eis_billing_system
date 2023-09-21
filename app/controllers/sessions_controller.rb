class SessionsController < ParentController
  allow_unauthenticated

  def new; end

  # def create
  #   user = User.find_by(email: params[:email])
  #   if user.present? && user.authenticate(params[:password])
  #     session[:user_id] = user.id
  #     redirect_to root_path, status: :see_other, flash: { notice: 'Logged in successfully' }
  #   else
  #     flash.now[:alert] = 'Wrong username/password'
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def destroy
    logout

    flash[:success] = t('.success')
    redirect_to root_path, status: :see_other
  end
end
