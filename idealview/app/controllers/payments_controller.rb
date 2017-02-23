class PaymentsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def select_plan

    
    @all_plans = Plan.all(:plan_id.ne => @infoBroker.plan)
    #abort("#{@infoBroker.inspect}")
    render partial: 'payments/select_plan'
 end

 def payment_successfull
    # require "stripe"
    # Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"

    # # broker = Stripe::Customer.create(
    # #   :description => "Brokers",
    # #   :source => params[:stripeToken],
    # #   :email => params[:email],
    # #   :plan => params[:plan]
    # # )
    
    # cu =  Stripe::Customer.retrieve("#{params[:customer_id]}")
    # unless params[:subscription_id].blank?
    #   subscription = cu.subscriptions.retrieve("#{params[:subscription_id]}")
    # else
    #   # abort("#{cu.subscriptions.first.id}")
    #   sub_id = "#{cu.subscriptions.first.id}"
    #   subscription = cu.subscriptions.retrieve("#{sub_id}")
    # end
    
    # subscription.plan = "#{params[:plan]}"
    # subscription.save
    plan = params[:plan].downcase
    subscription = Recurly::Subscription.find("#{params[:subscription_id]}")
    subscription.update_attributes(
      :plan_code => "#{plan}",
      :coupon_code => "#{params[:coupon_code]}",
      :timeframe => 'now'       # Update immediately.
      # :timeframe => 'renewal' # Update when the subscription renews.
    )

    # abort("#{subscription.inspect}")
    if subscription
      user = User.find_by_id(params[:user_id])
      user.customer_id = params[:customer_id]
      user.subscription_id = "#{subscription.uuid}"
      user.plan = "#{plan}"
      if plan == "enterprise"
        user.max_users = 15
        user.max_lenders = "No Limit"
        user.max_storage = "100Gb"
        user.max_upload = "No File Cap"
        user.pipelines = 1
        user.req_docs = 1
        user.forward_email = 1
        user.market_access = 1
        unless user.name.blank?
          uname = user.name.downcase
          uname=uname.gsub(' ','_')
        else 
          uname = "user"
        end
        time_now = Time.now.strftime("%m%d%y%H%M%S")
        sys_email = "#{uname}#{time_now}@idealview.us"
        user.system_email = "#{sys_email}"

      elsif plan == "business"
        user.max_users = 5
        user.max_lenders = "No Limit"
        user.max_storage = "5Gb"
        user.max_upload = "25Mb"
        user.pipelines = 1
        user.req_docs = 1
      end 
        

      user.save

      brokr = Broker.find_by_id(params[:broker_id])
      brokr.plan = "#{params[:plan]}"
      if brokr.save
        # abort("#{user.inspect}")
        LoanUrlMailer.new_plan(params[:plan], params[:email]).deliver
        #abort("#{broker.id}")
        render text: "#{params[:plan]}"
      end
    end
 end

 def subscribe_plan
    if @infoBroker.plan == "BUSINESS" || @infoBroker.plan == "ENTERPRISE"
      redirect_to action: 'billing'
    end
    @all_plans = Plan.all(:plan_id.ne => @infoBroker.plan)
 end

  def proceed_payment
      user = User.find_by_id(params[:user_id])
      plan = params[:plan].downcase

      unless params[:recurlytoken].blank?
        subscription = Recurly::Subscription.create(
        :plan_code => "#{plan}",
        :currency  => 'USD',
        :customer_notes  => 'Thank you for your business!',
        :coupon_code => "#{params[:coupon_code]}",
        :account   => {
          :account_code => "#{user.id}",
          :email        => "#{user.email}",
          :first_name   => "#{params[:firstName]}",
          :last_name    => "#{params[:lastName]}",
          billing_info: { token_id: "#{params[:recurlytoken]}" }
        }
        )
      end
      # user.customer_id = broker.id
      # abort("#{subscription.inspect}")
      user.subscription_id = subscription.uuid
      user.with_recurly = 1
      user.plan = "#{plan}"
      @plan = "#{plan}"

      if @plan == "enterprise"
        user.max_users = 15
        user.max_lenders = "No Limit"
        user.max_storage = "100Gb"
        user.max_upload = "No File Cap"
        user.pipelines = 1
        user.req_docs = 1
        user.forward_email = 1
        user.market_access = 1
      elsif @plan == "business"
        user.max_users = 5
        user.max_lenders = "No Limit"
        user.max_storage = "5Gb"
        user.max_upload = "25Mb"
        user.pipelines = 1
        user.req_docs = 1
      end 
      
      user.save

      brokr = Broker.find_by_id("#{params[:broker_id]}")
      # abort("#{brokr.inspect}")
      # brokr.customer_id = broker.id
      brokr.plan = "#{params[:plan]}"
      # abort("#{subscription.inspect}")
      if brokr.save

      LoanUrlMailer.new_plan(params[:plan], "#{user.email}").deliver
      #abort("#{broker.id}")
        redirect_to action: 'billing', id: 'free'
      end
   
 end

 def expand_memory
  # abort("#{current_user.inspect}")
 end

 def expand_memory_payment
    uInfo = User.find_by_id("#{params[:user_id]}")
    transaction = Recurly::Transaction.create(
        :amount_in_cents => 2000,
        :currency        => 'USD',
        :description     => 'Expand Memory',
        :account         => {
          :account_code => "#{uInfo.id}"
        }
      )
    expand=1
    unless uInfo.expand_memory.blank?
      expand = uInfo.expand_memory + expand
    end

    uInfo.expand_memory = expand
    uInfo.save
    redirect_to action: 'expand_memory', id:"done"
    
 end

 def billing
  
  if current_user.blank?
    redirect_to "/"
  else

  if params[:u]
    @update_tab = true
  end
  @from_free = ""
  unless params[:id].blank?
    @from_free = "yes"
  end
  # abort("dfsdf")
  @account = Recurly::Account.find("#{current_user.id}")
  
  acc_invoices = Array.new

  @account.invoices.find_each do |invoice|
    in_voice = invoice.line_items
    acc_invoices << "Invoice: #{in_voice}"
  end
  end

  # @account.adjustments.find_each do |adjustment|
  #   acc_invoices << "Adjustment: #{adjustment.end_date}"
  # end

  # abort("#{acc_invoices.inspect}")
  
 end

 def payment_history
  @account = Recurly::Account.find("#{current_user.id}")
  acc_invoices = Array.new
  @account.invoices.find_each do |invoice|
    in_voice = invoice.line_items
    acc_invoices << "Invoice: #{in_voice}"
  end
  render partial: 'payments/payment_history'
 end 

 def next_payment
  @subscription = Recurly::Subscription.find("#{current_user.subscription_id}")
  # abort("#{subscription.current_period_ends_at}")
  render partial: 'payments/next_billing'
 end 

 def change_billing_info
  render partial: 'payments/change_billing_info'
 end

 def pdf_invoice
  begin
    pdf = Recurly::Invoice.find(
      "#{params[:id]}", :format => 'pdf'
    )

  rescue Recurly::Resource::NotFound => e
    redirect_to action: 'billing'
  else
    send_data(pdf, :filename => "invoice_#{params[:id]}.pdf", :type => "application/pdf")
  end
 end

 def change_info
  unless params[:recurlytoken].blank?
    account = Recurly::Account.find("#{current_user.id}")
    account.billing_info.token_id = "#{params[:recurlytoken]}"
    account.billing_info.save!
  end

  render text:'done'
 end

 def environmental_api

  uri = URI.parse("https://www.sitelynx.net/api/sessions.json");
  # abort("#{uri.port}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
  request = Net::HTTP::Post.new(uri.request_uri)
  # request.set_form_data({"api_key" => "aae5b42c3f0997b8c6c5596b9c1856d89fd25ebe"})
  request.set_form_data({"username"=> "cache", "password" => "george10416"} )
  response = http.request(request)
  jresult = response.body
  # drop_result = JSON.parse(jresult)

  abort("#{jresult.inspect}")

 end

 def check_uniq val
  @val = val
  @report = Report.find_by_client_id("#{@val}")
  if @report.blank?
    return @val
  else
    @val = @val.to_i+1
    check_uniq(@val)
  end
 end
 
 def generate_report
    @collateral = Collateral.find_by_id("#{params[:id]}")

    
    time_nw = Time.now
    str_time = time_nw.strftime("%Y%m%d%H%M%S")

    @client_id = check_uniq("#{str_time}")
    
    
    if params[:type] == "environmental"
      @amount = 375
      @scope = "CPM"
    else
      @amount = 1900
      @scope = "ESA"
    end
 end

 def report_payment
  # abort("#{params.inspect}")
  @amount = params[:amount].to_i * 100
  @transaction = Recurly::Transaction.create(
      :amount_in_cents => @amount,
      :currency        => 'USD',
      :account         => {
        :account_code => params[:collateral_id],
        :billing_info => {
         token_id: "#{params[:recurlytoken]}"
        }
      }
    )
 
  @report = Report.new
  @report.transaction_id = @transaction.id
  @report.collateral_id = params[:collateral_id]
  @report.loan_id = params[:loan_id]
  @report.save

  render text:"#{@report.id}"

 end

 def report_generate
  uri = URI.parse("https://www.sitelynx.net/api/sessions.json");
  # abort("#{uri.port}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
  request = Net::HTTP::Post.new(uri.request_uri)
  # request.set_form_data({"api_key" => "aae5b42c3f0997b8c6c5596b9c1856d89fd25ebe"})
  request.set_form_data({"username"=> "cache", "password" => "george10416"} )
  response = http.request(request)
  jresult = response.body
  json_response = JSON.parse(jresult)
  
  headers = {"Authorization" => "#{json_response['api_key']}", "Content-Type" => "application/json" }
  uri = URI.parse("https://www.sitelynx.net/api/projects.json");
   
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
  
  request = Net::HTTP::Post.new(uri.request_uri)
  # data = {"project_name" => "The  Bowling Alley", "client_number" => "12312", "address" => "123  Hope  Dr.", "city" => "Hollywood", "state" => "CA", "zip" => "90299", "property_type" => "commercial", "project_scope" => "CPM", "notes" =>  "we  have  previous  phase Is"}
  data = {"project_name" => "#{params[:project_name]}", "client_number" => "#{params[:client_number]}", "address" => "#{params[:address]}", "city" => "#{params[:city]}", "state" => "#{params[:state]}", "zip" => "#{params[:zip]}", "property_type" => "#{params[:property_type]}", "project_scope" => "#{params[:project_scope]}", "notes" =>  "#{params[:notes]}"}
  jdata = data.to_json
  response = http.post(uri.path, jdata, headers)
  rsp = response.body
  objArray = JSON.parse(rsp)
  rsp = response.body
 
  begin
      @objArray = JSON.parse(rsp)
      
      rescue Exception => exc
      if exc.message
        error = 1
      end
  end
  unless @objArray.blank?
    @report = Report.find_by_id("#{params[:report_id]}")
    unless @report.blank?
      @report.client_id = "#{params[:client_number]}"
      @report.sitelynx_id = "#{@objArray['sitelynx_id']}"
      @report.api_key = "#{json_response['api_key']}"
      @report.save
    end

    render text: "done"
  else
    render text: "error"
  end
 end
  
  
end
