class HomeController < ApplicationController
  before_filter :authenticate_user, :only => [:home, :profile, :setting]
  before_filter :save_login_state, :only => [:login, :login_attempt]
  

  def index

    # abort("#{params}")
    # users = User.all
    # uname= Array.new
    # i=0
    # users = User.all
    # userInfo = Array.new
    # users.each do |user|
    #   @roles = uInfo.roles
    #   @roles.each do |role|
    #     @names = role['name']
    #   end

    #   check_admin = @names.include? 'Admin'
    #   if check_admin==""
    # end
    

    # users.each do |user|
    #   uInfo = User.find_by_id(user.id)
    #   user_name = ""
    #   unless uInfo.name.blank?
    #     name = uInfo.username.gsub('.','');
    #     if uname.include? "#{name.downcase}"
    #       i += 1
    #       uname<<"#{name.downcase}#{i}"
    #       sub_domain = "#{name.downcase}#{i}"
    #     else
    #       uname<<name.downcase
    #       sub_domain = name.downcase
    #       sub_domain = sub_domain.gsub('_',''); 
    #     end
        
    #   else
    #     array_name = uInfo.email.split(/@/)
    #     unless uname.include? "#{array_name[0]}"
    #       i += 1
    #       uname<<"#{array_name[0].downcase}#{i}"
    #       sub_domain = "#{array_name[0].downcase}#{i}"
    #       sub_domain = sub_domain.gsub('_',''); 
    #     else
    #       uname << "#{array_name[0].downcase}"
    #       sub_domain = "#{array_name[0].downcase}"
    #        sub_domain = sub_domain.gsub('_',''); 
    #     end
    #   end
      
    #   uInfo.subdomain = sub_domain
    #   uInfo.save
    # end
    # subd = Array.new
    # users.each do |user|
    #   subd<<user.subdomain
    # end
    #  abort("#{subd.inspect}")
# abort("#{request.subdomain}")
    unless current_user.blank?
          # abort("#{current_user.inspect}")
        # if current_user.email=="preet@gmail.com"
        #       # abort("#{@brokerLogin}")
              
        #       ################# Transfer Data to new DB ################
        #       @user = User.find_by_email("#{current_user.email}")
        #       if @brokerLogin==true
        #         bemail = "#{current_user.email}"
        #         @broker = Broker.find_by_email(bemail.to_s)
        #       end
        #       @terms = TermCondition.find_by_type("shop_loans")
        #       MongoMapper.database = "#{current_user.username}"
        #       @userI = User.new
        #       @userI = @user
        #       @userI.save

        #       @bterm = TermCondition.find_by_type("shop_loans")
        #       if @bterm.blank?
        #         term_condition = TermCondition.new
        #         term_condition = @terms
        #         term_condition.save
        #       end 

        #       if @brokerLogin==true
        #         bemail = "#{current_user.email}" 
        #         @new_broker = Broker.find_by_email(bemail.to_s)

        #         if @new_broker.blank?
        #           brokr = Broker.new
        #           brokr = @broker
        #           brokr.save
        #         end
        #       end
        #       ################# Transfer Data to new DB ################



              
        # end
        cookies[:logoutFd] = "done"
        
        cname="#{current_user.name}/#{request.subdomain}"
        str = Base64.encode64("#{cname}")
        if @adminLogin!=true
          if @lenderLogin == true && @infoBroker.plan == "lender"
            redirect_to "https://idealview.us/?idvkey_token="+str+"&return_url=idvstage&type=lender"
          else
            redirect_to "https://idealview.us/?idvkey_token="+str+"&return_url=idvstage"
          end
        else
          redirect_to "https://idealview.us/?idvkey_token="+str+"&return_url=idvstage"
        end
    else
      session[:cpc_login] = ""
      session[:cpc_url] = ""
      if cookies[:logoutFd]
        cookies.delete :logoutFd
        redirect_to "https://idvstage.us/?idvaction=signout"
      end
      # abort("#{params.inspect}")
    end


  end

  def broker_check
  end
  
  def test
    @contact = Infusionsoft.data_load('Contact', 925, [:FirstName, :LastName])
  end

  def sign_up


    @current_year = Date.today.strftime("%Y")
    @plan = params[:plan]
    @pInfo = Plan.find_by_plan_id(params[:plan].upcase)
    
   
    pplan = Plan.find_by_name("ENTERPRISE PLAN")
    pplan.amount = "24900"
    pplan.save
    # Plan.delete_all(:name => "PRO PLAN")

     @plans=Plan.all
    # abort("#{@plans.inspect}")

    
    unless current_user.blank?
      redirect_to controller:"loans"
    end
  end

  # def create_broker

  #   unless params[:stripeToken].blank?
  #     require "stripe"
  #     Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"

  #     broker = Stripe::Customer.create(
  #       :description => "Brokers",
  #       :source => params[:stripeToken],
  #       :email => params[:email],
  #       :plan => params[:plan]
  #     )

  #    end


  #   user = User.new
  #   user.name = "#{params[:firstName]} #{params[:lastName]}"
  #   user.email = params[:email]
  #   usrname = params[:username].downcase
  #   user.username = usrname.gsub(' ','')
  #   uname = usrname.gsub(' ','')
  #   sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
  #   user.subdomain = sub_domain
  #   unless params[:stripeToken].blank?
  #     user.subscription_id = "#{broker.subscriptions.first.id}"
  #   end
  #   user.password = params[:password]
  #   @roles = Array.new
  # @roles.push(Role.new(:name=>'Broker'))
  # user.roles = @roles
  # unless params[:stripeToken].blank?
  #     user.customer_id = broker.id
  #   end
  #   user.plan = params[:plan]
  #   #abort("#{user.inspect}")
  #   user.save

  #   brokr = Broker.new
  #   brokr.firstName = params[:firstName]
  #   brokr.lastName = params[:lastName] 
  #   brokr.name = "#{params[:firstName]} #{params[:lastName]}"
  #   unless params[:company].blank?
  #     brokr.company = params[:company]
  #   end
  #   unless params[:jobTitle].blank?
  #     brokr.jobTitle = params[:jobTitle]
  #   end
  #   unless params[:streetAddress1].blank?
  #     brokr.streetAddress1 = params[:streetAddress1]
  #   end
  #   unless params[:city].blank?
  #     brokr.city = params[:city]
  #   end
  #   unless params[:state].blank?
  #     brokr.state = params[:state]
  #   end
  #   unless params[:postalCode].blank?
  #     brokr.postalCode = params[:postalCode]
  #   end
  #   unless params[:stripeToken].blank?
  #     brokr.customer_id = broker.id
  #   end
  #   brokr.plan = params[:plan]
  #   brokr.email = params[:email]
  #   brokr.password = params[:password]
  #   #abort("#{brokr.inspect}")
  #   brokr.save
  #   LoanUrlMailer.welcome_email(brokr.id).deliver
  #   flash[:messages] = "Your account is created successfully"  
  #   # redirect_to :action => 'index', :id => 'success'
  #   pass = "1dealv1ew"
  #   femail = AESCrypt.encrypt("#{params[:email]}", pass)
  #   fpass = AESCrypt.encrypt("#{params[:password]}", pass)
  #   redirect_to :action => "funding_login", :a => femail, :b => fpass
  # end

  def create_broker

    
  user = User.new
  uname = "#{params[:firstName]} #{params[:lastName]}"
  user.name = uname.camelize
  user.email = params[:email]
  usrname = params[:username].downcase
  user.username = params[:username]
  uname = usrname.gsub(' ','')
  sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
  user.subdomain = sub_domain
  user.password = params[:password]
  user.user_password = params[:password]
  @roles = Array.new
  @roles.push(Role.new(:name=>'Broker'))
  user.roles = @roles
  plan = params[:plan].downcase
  unless params[:recurlytoken].blank?
    subscription = Recurly::Subscription.create(
    :plan_code => "#{plan}",
    :currency  => 'USD',
    :customer_notes  => 'Thank you for your business!',
    :account   => {
      :account_code => "#{user.id}",
      :email        => "#{params[:email]}",
      :first_name   => "#{params[:firstName]}",
      :last_name    => "#{params[:lastName]}",
      billing_info: { token_id: "#{params[:recurlytoken]}" }
    }
    )
  end
  
  # account = Recurly::Account.create(
  # :account_code => '1',
  # :email        => 'verena@example.com',
  # :first_name   => 'Verena',
  # :last_name    => 'Example'
  # )

  # abort("#{subscription.inspect}")


    
    unless params[:recurlytoken].blank?
      user.subscription_id = subscription.uuid
      user.with_recurly = 1
    end
    user.plan = params[:plan]
    if params[:plan]=="free"
      user.max_users = "1"
      user.max_lenders = "5"
      user.max_storage = "1GB"
      user.max_upload = "10MB"
      user.pipelines = 0
      user.req_docs = 0
      user.loan_application_links = 0
      user.forward_email = 0
    elsif params[:plan]=="BUSINESS"
      user.max_users = "5"
      user.max_lenders = "No Limit"
      user.max_storage = "5GB"
      user.max_upload = "25MB"
      user.pipelines = 1
      user.req_docs = 1
      user.loan_application_links = 0
      user.forward_email = 0
    
    elsif params[:plan]=="ENTERPRISE"
      user.max_users = "15"
      user.max_lenders = "No Limit"
      user.max_storage = "100GB"
      user.max_upload = "No File Cap"
      user.pipelines = 1
      user.req_docs = 1
      user.loan_application_links = 1
      user.forward_email = 1
    end
    #abort("#{user.inspect}")
    user.save
   
      brokr = Broker.new
      brokr.firstName = params[:firstName]
      brokr.lastName = params[:lastName] 
      brokr.name = "#{params[:firstName]} #{params[:lastName]}"
      unless params[:company].blank?
        brokr.company = params[:company]
      end
      unless params[:jobTitle].blank?
        brokr.jobTitle = params[:jobTitle]
      end
      unless params[:streetAddress1].blank?
        brokr.streetAddress1 = params[:streetAddress1]
      end
      unless params[:city].blank?
        brokr.city = params[:city]
      end
      unless params[:state].blank?
        brokr.state = params[:state]
      end
      unless params[:postalCode].blank?
        brokr.postalCode = params[:postalCode]
      end
      unless params[:stripeToken].blank?
        brokr.customer_id = broker.id
      end
      brokr.plan = params[:plan]
      brokr.email = params[:email].downcase
      brokr.password = params[:password]
      #abort("#{brokr.inspect}")
      brokr.save
      LoanUrlMailer.welcome_email(brokr.id).deliver
      # flash[:messages] = "Your account is created successfully"  
      # redirect_to :action => 'index', :id => 'success'

      pass = "1dealv1ew"
      femail = AESCrypt.encrypt("#{params[:email]}", pass)
      fpass = AESCrypt.encrypt("#{params[:password]}", pass)
      redirect_to :action => "funding_login", :a => femail, :b => fpass
   
  end


  def checkemail
  	user = User.find_by_email("#{params[:email]}")
  	if user.blank?
      email = params[:email].downcase
      user = User.find_by_email("#{email}")
    end
    if user.blank?
  		render plain: 'true'
  	else
  		render plain: 'false'
  	end
  end

  def checkuname
    
    user = User.find_by_username("#{params[:username]}")
    if user.blank?
      uname = params[:username].downcase
      user = User.find_by_username("#{uname}")
    end
    if user.blank?
      render plain: 'true'
    else
      render plain: 'false'
    end
  end

  def login
      authorized_user = User.authenticate(params[:email],params[:password])
      if authorized_user
        session[:user_id] = authorized_user.id
        session[:current_user] = authorized_user
        @current_user = authorized_user

        uInfo  = User.find_by_email("#{current_user.email}")
        flash[:notice] = "Wow Welcome again, you logged in as #{authorized_user.email}"
        redirect_to(:controller => 'loans', :action => 'index')
      else
        flash[:notice] = "Invalid Username or Password"
        flash[:color]= "invalid"
        render "login"  
      end
  end

  def login_page
    # crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    pass = "1dealv1ew"
    femail = AESCrypt.encrypt("#{params[:email]}", pass)
    fpass = AESCrypt.encrypt("#{params[:password]}", pass)
    redirect_to :action => "funding_login", :a => femail, :b => fpass
  end

  def funding_login
    pass = "1dealv1ew"
    @email = AESCrypt.decrypt("#{params[:a]}", pass)
    @password = AESCrypt.decrypt("#{params[:b]}", pass)
  end

  # def cpc_login_page
  #   # crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
  #   uInfo = User.find_by_id("#{params[:token]}")
  #   pass = "1dealv1ew"
  #   femail = AESCrypt.encrypt("#{uInfo['email']}", pass)
  #   fpass = AESCrypt.encrypt("#{uInfo['user_password']}", pass)
  #   redirect_to :action => "cpc_login", :a => femail, :b => fpass
  # end

   def cpc_login_page
    # crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    require 'net/http'
    require 'uri'
    str_url = "#{request.referer}"
    # redirect_url = str_url.gsub('site/idvlogin', 'site/idvloginres')
    # abort("#{str_url}")
    # cpc_url = URI.parse(str_url).host 
    cpc_url =  session[:cpc_url]
    # abort("#{cpc_url.inspect}")
    redirect_url = "http://#{cpc_url}/index.php?r=site/idvloginres"
    
    if current_user.blank?
      uInfo = User.find_by_id("#{params[:token]}")

      unless uInfo.blank?
        @email = uInfo.email
        @password = uInfo.user_password  
        unless params[:uname].blank?
          uInfo.cpc_username = "#{params[:uname]}"
          uInfo.save
        end
        unless redirect_url.blank?
          # abort("#{redirect_url}")
          uri = URI.parse("#{redirect_url}");
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data({"status" => 1, "referalurl" => "https://dash.idealview.us", "token" => "#{params[:token]}" })
          response = http.request(request)
          # abort("#{response.inspect}")
        end
        # abort("#{response}")
      else
        unless redirect_url.blank?
          uri = URI.parse("#{redirect_url}");
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri)
          request.set_form_data({"status" => 0, "referalurl" => "https://dash.idealview.us", "token" => "#{params[:token]}" })
          response = http.request(request)
        end

      end


   else
    
     @cpc_url = "#{session[:cpc_url]}"
     # abort("#{@cpc_url}")
     redirect_to @cpc_url
   end

  end

  def cpc_login
    pass = "1dealv1ew"
    @email = AESCrypt.decrypt("#{params[:a]}", pass)
    @password = AESCrypt.decrypt("#{params[:b]}", pass)
  end


  def save_val
    session[:password] = params[:val] 
    render text: "done"
  end

  def logout
    redirect_to "https://idealview.us/?idvaction=signout&return_url=idvstage"
  end

  def idv_login
    resource = User.find_for_database_authentication(:email => params[:user_login][:email])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user_login][:password])
       uInfo = User.find_by_id(resource.id)
      unless uInfo.blank?
        uInfo.user_password = "#{params[:user_login][:password]}"
        uInfo.save
      end
      # uInfoz = User.find_by_id("#{resource.id}")
      # abort("#{uInfoz.inspect}")
      
      sign_in(:user, resource)
      # resource.id!
      render :json=> {:token=>resource.id, :email=>resource.email}, :status => :ok
      return
    end
    invalid_login_attempt
  end

   def recieve_funding
    rsp=Hash.new
     # abort("#{params.inspect}")
      rsp['status'] = 1
      rsp['msg'] = "Text"
    render json: rsp 
  end

   protected
  def ensure_params_exist 
  return unless params[:user_login].blank?
    render :json=>{:message=>"missing user_login parameter"}, :status=>422
  end
  def invalid_login_attempt
    render :json=> {:message=>"Error with your login or password"}, :status=>401
  end



end
