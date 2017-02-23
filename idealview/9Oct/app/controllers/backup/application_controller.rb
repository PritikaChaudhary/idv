class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include Pundit
  protect_from_forgery

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  before_action :configure_permitted_parameters, if: :devise_controller?

  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation) }

  end
  before_filter :check_admin
  helper_method :app_name

  private
    def app_name
      Rails.application.class.to_s.split("::").first
    end
    
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

    def check_admin
       if !current_user.blank?
        roles=current_user.roles
        @names = Array.new
        roles.each do |role|
          @names << role.name
        end
        checkAdmin = @names.include?('Admin') 
        checkBroker = @names.include?('Broker')
      end

      if checkBroker==true
          @infoBroker = Broker.find_by_email(current_user.email)
      end
    end

  
  
end
