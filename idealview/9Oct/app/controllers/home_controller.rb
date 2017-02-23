class HomeController < ApplicationController
ActionController::Base.helpers
  
  def index
  	
  	unless params[:id].blank?
  		@success = params[:id]
  	end
  	unless current_user.blank? 
	  	roles=current_user.roles
	    @names = Array.new
	    roles.each do |role|
	      @names << role.name
	    end

	    @checkAdmin = @names.include?('Admin')
	    @checkBroker = @names.include?('Broker')
	  	
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
    @pInfo = Plan.find_by_plan_id(params[:plan])
    @plans = Plan.all
  end

  def create_broker

  	unless params[:stripeToken].blank?
	  	require "stripe"
	    Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"

	    broker = Stripe::Customer.create(
	      :description => "Brokers",
	      :source => params[:stripeToken],
	      :email => params[:email],
	      :plan => params[:plan]
	    )


	   end


  	user = User.new
  	user.name = "#{params[:firstName]} #{params[:lastName]}"
  	user.email = params[:email]
  	user.password = params[:password]
  	@roles = Array.new
	@roles.push(Role.new(:name=>'Broker'))
	user.roles = @roles
	unless params[:stripeToken].blank?
  		user.customer_id = broker.id
  	end
  	user.plan = params[:plan]
  	#abort("#{user.inspect}")
  	user.save
    
    unemail = params[:email].split("@")[0]

    uemail = unemail.gsub!(/[^A-Za-z]/, '')
    bucket_name = user.id.to_s+uemail.to_s 
    
    bucket = S3.create_bucket(bucket: bucket_name)
    user.bucket_name = bucket_name
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
  	brokr.email = params[:email]
  	brokr.password = params[:password]
  	#abort("#{brokr.inspect}")
  	brokr.save
    #LoanUrlMailer.welcome_email(brokr.id).deliver
  	flash[:messages] = "Your account is created successfully"  
    redirect_to :action => 'index', :id => 'success'

  end

  def checkemail
  	user = User.find_by_email(params[:email])
  	if user.blank?
  		render plain: 'true'
  	else
  		render plain: 'false'
  	end
  end
end
