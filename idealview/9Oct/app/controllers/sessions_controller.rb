class SessionsController < ApplicationController

 def log_in(user)
    session[:user_id] = user.id
  end

def create 
    #user = User.where(:email => params[:session][:email].downcase).first
    user = User.find_by_msisdn(params[:msisdn])
    # abort("#{user.inspect}")
   
    sign_in(user)

    #redirect_to '/'
     
    redirect_to after_sign_in_path(user)

    # user = User.authenticate(params[:session][:email], params[:session][:password])
    # abort("#{user.inspect}")
    # if user 
    #   # Log the user in and redirect to the user's show page.

    #   #  user = User.find_by_msisdn(params[:msisdn])
    #   # if user.nil?
    #   #   user = User.create(field_1: value1, field_2: value2)    
    #   # end


    #   sign_in(user)

    #   # redirect_to after_sign_in_path(user)
    #    # log_in user
    #   # remember user
    #   redirect_to '/'
    #   #abort("#{user.inspect}")
    # else
    #   # Create an error message.
    #   abort("Hey...")
    # end
end

def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

end
