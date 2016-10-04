  before_action :check_if_logged_in

  layout 'admin'

  def index
  end

  private

  def current_user
    return User.first if Rails.env.development?
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end
  helper_method :current_user

  def check_if_logged_in
    return true if Rails.env.development?
    return true if current_user.present?
    session[:return_to_url] = request.url
    redirect_to new_admin_session_path
  end
