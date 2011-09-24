# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new

  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Logged in successfully"
      redirect_to home_users_path
    else
      flash[:notice] = "Please Enter Valid Email_id and Password"
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
    # render :controller =>'home', :action => 'index'
    redirect_to home_index_path
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out successfully."
    redirect_to root_path
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
