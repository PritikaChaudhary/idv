class SubscribeController < ApplicationController
ActionController::Base.helpers
  

  def sign_up
       require "stripe"
      Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"
      plans = Stripe::Plan.all
      
      plans.each do |plan|
        planInfo = Plan.find_by_plan_id(plan.id)
       if planInfo.blank?
          new_plan = Plan.new
          new_plan.plan_id = plan.id
          new_plan.name = plan.name
          new_plan.amount = plan.amount
          new_plan.currency = plan.currency
          new_plan.interval = plan.interval
          new_plan.save
        else
         planInfo.plan_id = plan.id
          planInfo.name = plan.name
          planInfo.amount = plan.amount
          planInfo.currency = plan.currency
          planInfo.interval = plan.interval
          planInfo.save
        end
      end
    @current_year = Date.today.strftime("%Y")
  	@plan = params[:plan].upcase
    #abort("#{@plan}")
    @pInfo = Plan.find_by_plan_id(@plan) 
    #abort("#{@pInfo.inspect}")
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
	    )
      subscription = broker.subscriptions.create({:plan => params[:plan]})
      
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
      user.subscription = subscription.id
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
    setup_new_user(user.id)
    LoanUrlMailer.welcome_email(brokr.id).deliver
  	flash[:messages] = "Your account is created successfully"  
    redirect_to :controller => 'home', :action => 'index', :id => 'success'

  end

   def setup_new_user id
    require "yaml/store"
    file_name = YAML::Store.new "#{Rails.root}/config/settings/#{id}.yml"
    user=User.find_by_id(id)
    user_id = user.id.to_s

    #abort("#{user_id}")
    file_name.transaction do 
      file_name["settings"] = { "cid" => "#{user_id.to_s}","plan_type" => user.plan, "sub_id" => user.subscription, "db" => "#{user_id}", "bucket" => user.bucket_name  }
      #  else
      #file_name["settings"] = { "cid" => user.customer_id,"plan_type" => user.plan, "sub_id" => user.subscription, "db" => user.customer_id, "bucket" => user.bucket_name  }
     # end
    end
  end

  def checkemail
  	user = User.find_by_email(params[:email])
  	if user.blank?
  		render plain: 'true'
  	else
  		render plain: 'false'
  	end
  end

  def index
    if current_user.blank?
      redirect_to '/users/sign_in'
    elsif @adminLogin != true
      redirect_to '/users/sign_in'
    end
    @brokers = Broker.all(:delete.ne => 1, :plan.ne => nil)
    #abort("#{@brokers.inspect}")
  end
end
