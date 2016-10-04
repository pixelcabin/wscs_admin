class Admin::SessionsController < Admin::BaseController
  layout 'admin_unauthenticated'
  skip_before_action :check_if_logged_in, only: %i(new create)

  def new
    redirect_to admin_root_path if current_user
    @user = User.new
  end

  def create
    @user = User.find_by_email!(user_params[:email])
    if @user && @user.authenticate(user_params[:password])
      session[:user_id] = @user.id
      redirect_back_or_to admin_root_path
    else
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to new_admin_session_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end

  def redirect_back_or_to(url, flash_hash = {})
    redirect_to(session[:return_to_url] || url, :flash => flash_hash)
    session[:return_to_url] = nil
  end
end
