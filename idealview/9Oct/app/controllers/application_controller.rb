class ApplicationController < ActionController::Base
 # include MongoMapper::Document
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
      host_name = request.host
      @portnum =  request.port

      # bucket = S3.Bucket.new('idv_users')
      if host_name=="localhost"
        @hostname = "#{host_name}:#{@portnum}"
      else
        @hostname = host_name
      end
      #######################################

       if !current_user.blank?
        roles=current_user.roles
        @names = Array.new
        roles.each do |role|
          @names << role.name
        end
        checkAdmin = @names.include?('Admin') 
        checkBroker = @names.include?('Broker')
        @brokerLogin = @names.include?('Broker')
        @adminLogin = @names.include?('Admin') 

        # if defined? current_user.bucket_name && current_user.bucket_name!= nil 
        #    @bucketName = current_user.bucket_name
        #     # new_bucket = S3::Bucket.find("#{@bucketName}")
        #     # new_bucket.each do |object|
        #     #         puts "#{object.key}\t#{object.about['content-length']}\t#{object.about['last-modified']}"
        #     # end
        #     resp = S3.list_objects(bucket: "#{@bucketName}")
        #     bucket_size = 0
        #     resp.contents.each do |object|
        #       bucket_size = bucket_size+object.size
        #     end
        #     #bucket = S3.bucket[current_user.bucket_name] # makes no request
        #      # check = bucket.exists?
        #     abort("#{bucket_size.inspect}")
        #  end 
      end

      if checkBroker==true
          @infoBroker = Broker.find_by_email(current_user.email)
          
         
      end
      ################################################
      if !current_user.blank?
       require "yaml/store"
        #include MongoMapper::Document
        file_path = "#{Rails.root}/config/settings/#{current_user.id}.yml"
        
        # Settings.usercfg =  YAML.load_file("#{file_path}")
        # Settings.currentuser = current_user
        # usr = User.find_by_id(current_user.id)
      # usr.loginuser
         #abort("#{@user_config['settings']['db']}")
         
        #connection(Mongo::Connection.new('localhost', 27017))
        #user_connection.set_database_name "#{@user_config['settings']['db']}"
      end
      ################################################
    end

  
  
end
