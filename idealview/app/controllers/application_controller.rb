class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper :all
  include Pundit
  # include MongoMapper::Document
  # protect_from_forgery except: :sign_in
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  before_action :configure_permitted_parameters, if: :devise_controller?
  set_current_tenant_by_subdomain(:user, :username)

  # force_ssl

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username

    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :password, :password_confirmation) }

  end
  # before_filter :authenticate_user, :only => [:login]
  # before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :check_admin

  helper_method :app_name

  def redirect_to_https
    
  end

  private
  
    def after_sign_in_path_for(resource)
      host_name = request.host
      @portnum =  request.port
      
      if host_name=="localhost"
        @hostname = "#{host_name}:#{@portnum}"
      else
        @hostname = host_name
      end

      ############ For New User ####################
          if !current_user.blank?
              userInfo = User.find_by_email("#{current_user.email}")
              checkLender = Lender.find_by_email("#{current_user.email}")
              if !checkLender.blank? && @lenderLogin != true
                  uInfo = User.find_by_email("#{current_user.email}")
                  @roles = uInfo.roles
                  
                  @names = Array.new
                  @roles.each do |role|
                      @names = role['name']
                  end

                  check_lender = @names.include? 'Lender'
                  check_broker = @names.include? 'Broker'
                  @checkAdmin = @names.include?('Admin') 
                  if check_lender==false || check_broker==false
                    if check_lender==false
                        @roles.push(Role.new(:name=>'Lender'))
                    end
                    if check_broker==false
                        @roles.push(Role.new(:name=>'Broker'))
                    end
                    uInfo.roles=@roles
                    uInfo.save
                  end
                  
                  checkBroker = Broker.find_by_email("#{current_user.email}")
                  if checkBroker.blank?
                      brok = Broker.new
                      brok.email = current_user.email
                      brok.lender = 1
                      brok.save
                  end   
                   @lenderLogin = true
                   @brokerLogin = true
                   checkBroker = true
                   request.referrer  
              end
             

          end
    ############ For New User ####################

      log_url = "#{request.referrer}"
      # if log_url != "https://#{@hostname}/users/sign_in" 
      #   if log_url.include? "https://dash.idealview.us/users/password/edit"
      #     super
      #   elsif log_url.include? "https://dash.idealview.us/home/funding_login"
      #     super
      #   else
      #    request.referrer 
      #   end
      # else
      #   super
      # end

       # abort("#{params.inspect}")
      #  if log_url != "https://#{@hostname}/users/sign_in" 
      #   if log_url.include? "https://dash.idealview.us/users/password/edit"
      #     super
      #   elsif log_url.include? "https://dash.idealview.us/home/funding_login"
      #     super
      #   else
      #    request.referrer 
      #   end
      # else
      #   super
      # end

      if params[:lenderDetail]
        request.referrer
      else
        super
      end
    
    end

    # def after_sign_out_path_for(resource)
    #   redirect_to "https://idealview.us/?action=signout" and return 
    # end


    def app_name
      Rails.application.class.to_s.split("::").first
    end
    
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referrer || root_path)
    end

    def check_admin
        # include MongoMapper::Document
       # User.current = @current_account
       # abort("#{@current_account}")
      # ActiveRecord::Base.establish_connection :pritika
      
      # set_current_tenant("pritika")
      # session[:user] = current_user

      # MongoMapper.database = "idealview_dev"
     # @users=User.all
     # abort("#{@users.inspect}")

      # uinfo = User.find_by_id("575e608eab608a1298000008")
      # abort("#{uinfo.inspect}")
      @hostname = request.host
      @portnum =  request.port

    # abort("#{current_user.inspect}")
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
        @lenderLogin = @names.include?('Lender')
      # else
      #   MongoMapper.database = "idealview_dev"
      end

      if checkBroker==true
          @infoBroker = Broker.find_by_email(current_user.email)
           @infoUser = User.find_by_email(current_user.email)
      end

      if checkAdmin==true
          @infoUser = User.find_by_email(current_user.email)
      end

      unless current_user.blank?
        @infoUser = User.find_by_email(current_user.email)
          @dropInfo = DropboxToken.find_by_user_id("#{current_user.id}")
          ##################### Memmory Size ######################

          docs = Document.where(:user_id=>"#{current_user.id}").fields(:file_size).all
          file_size = 0
          
          docs.each do |doc|
            unless doc.file_size.blank?
              file_size += doc.file_size
            end
          end

          other_docs = FolderFile.where(:user_id=>"#{current_user.id}").fields(:file_size).all
          other_docs.each do |other_doc|
            unless other_doc.file_size.blank?
              file_size += other_doc.file_size
            end
          end

          loan_images = Image.where(:user_id=>"#{current_user.id}").fields(:file_size).all
          loan_images.each do |loan_image|
            unless loan_image.file_size.blank?
              file_size += loan_image.file_size
            end
          end

          # abort("Documents #{docs.inspect} <br> #{other_docs.inspect} <br> #{loan_images.inspect}")
          @bucket_size = file_size

          ##################### Memmory Size End ##################
          

          ################# Bucket Size ###########################
          # buckets = StorageBucket.files
          # # abort("#{buckets.inspect}")


          # # abort("#{current_user.id}")
          # have_bucket = ""
          # @bucket_size = 0
          # buckets.each do |bucket|
          #   bname = bucket.key
          #   if bname.include? current_user.id
              
          #     have_bucket = "yes"
          #     @bucket_size = @bucket_size+bucket.content_length.to_f
          #   end
          # end
          # abort("#{@bucket_size}")
          # @bucket_byte = @bucket_size.to_f/1024

          # @bucket_mb = @bucket_byte.to_f/1024
          # abort("#{@bucket_mb}")
          @bucket_mb = @bucket_size
          if !@infoBroker.blank? && @infoBroker.plan=="free"
            #@max_size = 10022482
            @max_size = 1024
            if @bucket_mb < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
            # abort("#{@fileUpload}")
          elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
            
            @max_size = 5120
            if @bucket_mb < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end

          elsif !@infoBroker.blank? &&  @infoBroker.plan=="ENTERPRISE"
            
            # @alert_strg = 10

          ############### Memmory Expand Functionality ########################## 

            @max_size = 102400
            unless current_user.expand_memory.blank?
              expand = current_user.expand_memory*1024
              @max_size = 102400+expand
            else
              @max_size = 102400
            end
            @bucket_mb = @bucket_mb.round(2)
            
            @alert_memmory = @max_size-@bucket_mb
            @alert_msg = ""
            @alert_msgsub = ""
            @alert_msgdocs  =""

            # if @alert_msg <= 102391
            if @alert_memmory <= 10240
              @alert_msg = "true"
              @alert_msgsub = "true"
              @alert_msgdocs  ="true"
            end
          
          ############### End Memmory Expand Functionality ##########################
            
            if @bucket_mb < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end

          else
            @fileUpload = "true"
          end

      end
   
      ######################### Mongo DB Functions ##############################
      # require 'rubygems'
      # require 'mongo'
     
      # db = Mongo::Connection.new("localhost", 27017).db("pritika")
      # db.collection_names.each { |name| name }
      # coll = db.collection("testCollection")
      # coll = db["testCollection"]
      # doc = {"name" => "MongoDB", "type" => "database", "count" => 1,
      #  "info" => {"x" => 203, "y" => 102}}
      # coll.insert(doc)
      # testcoll = coll.testCollection.all()
      # abort("#{coll.inspect}")

      # connection = Mongo::Connection.new # (optional host/port args)
      # dbNames=Array.new
      # connection.database_names.each do |name|
      #   dbNames << name
      # end

      # abort("#{dbNames.inspect}")
      ######################### Mongo DB Functions ##############################
      
      
    
    end

    def authenticate_user

        if session[:user_id]
        # set current user object to @current_user object variable
         @current_user = User.find session[:user_id]
          return true 
        else
          redirect_to(:controller => 'sessions', :action => 'login')
          return false
        end
    end

    def save_login_state
        if session[:user_id]
        redirect_to(:controller => 'sessions', :action => 'home')
        return false
        else
        return true
        end
    end 

    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
        devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
    end
  
end
