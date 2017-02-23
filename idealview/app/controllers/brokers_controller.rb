class BrokersController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'

  @@color = "red"
  


  def index_m
   
  # brokers=Broker.all(email_status: 1)
   #brokers.each do |broker|
    #  LoanUrlMailer.email_broker(broker).deliver
   #end

 
   ###########################################
   @infusion_brokers = Infusionsoft.data_query('Contact',1000,0,{:ContactType=>'Broker'},Broker.highlight_fields)
   # abort("#{@infusion_brokers.inspect}")
    @infusion_brokers.each_with_index do |broker, i|
      pas_string = (0...8).map { (65 + rand(26)).chr }.join
      already=Broker.find_by_infusion_id(broker['Id'])
      unless already.blank?
        
        already.id = already.id
        already.firstName = broker['FirstName'] 
        already.lastName = broker['LastName']
        already.name = broker['FirstName']+' '+broker['LastName']
        already.company = broker['Company']
        already.jobTitle = broker['JobTitle']
        already.streetAddress1 = broker['StreetAddress1']
        already.streetAddress2 = broker['StreetAddress2']
        already.city = broker['City']
        already.state = broker['State']
        already.postalCode = broker['PostalCode']
        already.country = broker['Country']
        already.phone1 = broker['Phone1']
        already.phone2 = broker['Phone2']
        already.fax1 = broker['Fax1']
        already.email = broker['Email']
        already.website = broker['Website']
        already.address2Street1 = broker['Address2Street1']
        already.address2Street2 = broker['Address2Street2']
        already.city2 = broker['City2']
        already.state2 = broker['State2']
        already.postalCode2 = broker['PostalCode2']
        already.country2 = broker['Country2']
        already.address3Street1 = broker['Address3Street1']
        already.address3Street2 = broker['Address3Street2']
        already.city3 = broker['City3']
        already.state3 = broker['State3']
        already.postalCode3 = broker['PostalCode3']
        already.country3 = broker['Country3']
        if already.password.blank?
          already.password = pas_string
          pas_change = "yes"
        end
        already.save

        
          @check = User.find_by_email(broker['Email'])

          if @check.blank?
              @user = User.new
              authorize @user

              @roles = Array.new
              @roles.push(Role.new(:name=>'Broker'))
              @user.roles = @roles
              bname = broker['FirstName']+' '+broker['LastName']
              @user.name = bname.camelize
              @user.email = broker['Email']
              unless pas_change.blank?
                @user.password = pas_string
              end
              @user.save
              
              unless pas_change.blank?
                if already
                  LoanUrlMailer.email_broker(already).deliver
                  already.email_status = 1
                   already.save
                end 
             end
          else
            #abort("#{@check.roles}")
                  @roles = @check.roles
            
                  @names = Array.new
                  @roles.each do |role|
                    @names = role['name']
                  end

                  check_broker = @names.include? 'Broker'
                  if check_broker==false
                     @roles.push(Role.new(:name=>'Broker'))
                     @check.roles=@roles
                     @check.save
                  end
          end
        else
        
        db = Broker.new()
        db.infusion_id = broker['Id']
        db.firstName = broker['FirstName'] 
        db.lastName = broker['LastName']
        db.name = broker['FirstName']+' '+broker['LastName']
        db.company = broker['Company']
        db.jobTitle = broker['JobTitle']
        db.streetAddress1 = broker['StreetAddress1']
        db.streetAddress2 = broker['StreetAddress2']
        db.city = broker['City']
        db.state = broker['State']
        db.postalCode = broker['PostalCode']
        db.country = broker['Country']
        db.phone1 = broker['Phone1']
        db.phone2 = broker['Phone2']
        db.fax1 = broker['Fax1']
        db.email = broker['Email']
        db.website = broker['Website']
        db.address2Street1 = broker['Address2Street1']
        db.address2Street2 = broker['Address2Street2']
        db.city2 = broker['City2']
        db.state2 = broker['State2']
        db.postalCode2 = broker['PostalCode2']
        db.country2 = broker['Country2']
        db.address3Street1 = broker['Address3Street1']
        db.address3Street2 = broker['Address3Street2']
        db.city3 = broker['City3']
        db.state3 = broker['State3']
        db.postalCode3 = broker['PostalCode3']
        db.country3 = broker['Country3']
        db.password = pas_string
        db.save

         @check = User.find_by_email(broker['Email'])
         if @check.blank?
           @user = User.new
           authorize @user

           @roles = Array.new
           @roles.push(Role.new(:name=>'Broker'))
           @user.roles = @roles
           @user.name = broker['FirstName']+' '+broker['LastName']
           @user.email = broker['Email']
           @user.password = pas_string
           @user.save
            
           LoanUrlMailer.email_broker(db).deliver
           db.email_status = 1
           db.save
         else
            @roles = @check.roles
            
            @names = Array.new
            @roles.each do |role|
              @names = role['name']
            end

            check_broker = @names.include? 'Broker'
            if check_broker==false
               @roles.push(Role.new(:name=>'Broker'))
               @check.roles=@roles
               @check.save
            end
         end

      end
    end
    @brokers=Broker.all
   #abort("#{@brokers.inspect}")
  end

  def index
    @total = Broker.count(:delete.ne => 1)
    unless params[:per_page].blank?
      @brokers = Broker.paginate(:delete.ne => 1, :per_page => params[:per_page], :page => params[:page], :total_entries => @total, :plan.ne => "lender", :lender.ne => 1)
    else
      @brokers = Broker.paginate(:delete.ne => 1, :per_page => 10, :page => params[:page], :total_entries => @total, :plan.ne => "lender", :lender.ne => 1)
    end
  end

  def refresh_broker_bkup
    @infusion_brokers = Infusionsoft.data_query('Contact',1000,0,{:ContactType=>'Broker'},Broker.highlight_fields)
    @infusion_brokers.each_with_index do |broker, i|
      already=Broker.find_by_infusion_id(broker['Id'])
      unless already.blank?
        already.id = already.id
        already.firstName = broker['FirstName'] 
        already.lastName = broker['LastName']
        already.name = broker['FirstName']+' '+broker['LastName']
        already.company = broker['Company']
        already.jobTitle = broker['JobTitle']
        already.streetAddress1 = broker['StreetAddress1']
        already.streetAddress2 = broker['StreetAddress2']
        already.city = broker['City']
        already.state = broker['State']
        already.postalCode = broker['PostalCode']
        already.country = broker['Country']
        already.phone1 = broker['Phone1']
        already.phone2 = broker['Phone2']
        already.fax1 = broker['Fax1']
        already.email = broker['Email']
        already.website = broker['Website']
        already.address2Street1 = broker['Address2Street1']
        already.address2Street2 = broker['Address2Street2']
        already.city2 = broker['City2']
        already.state2 = broker['State2']
        already.postalCode2 = broker['PostalCode2']
        already.country2 = broker['Country2']
        already.address3Street1 = broker['Address3Street1']
        already.address3Street2 = broker['Address3Street2']
        already.city3 = broker['City3']
        already.state3 = broker['State3']
        already.postalCode3 = broker['PostalCode3']
        already.country3 = broker['Country3']

        already.save
      else

        db = Broker.new()
        db.infusion_id = broker['Id']
        db.firstName = broker['FirstName'] 
        db.lastName = broker['LastName']
        db.name = broker['FirstName']+' '+broker['FirstName']
        db.company = broker['Company']
        db.jobTitle = broker['JobTitle']
        db.streetAddress1 = broker['StreetAddress1']
        db.streetAddress2 = broker['StreetAddress2']
        db.city = broker['City']
        db.state = broker['State']
        db.postalCode = broker['PostalCode']
        db.country = broker['Country']
        db.phone1 = broker['Phone1']
        db.phone2 = broker['Phone2']
        db.fax1 = broker['Fax1']
        db.email = broker['Email']
        db.website = broker['Website']
        db.address2Street1 = broker['Address2Street1']
        db.address2Street2 = broker['Address2Street2']
        db.city2 = broker['City2']
        db.state2 = broker['State2']
        db.postalCode2 = broker['PostalCode2']
        db.country2 = broker['Country2']
        db.address3Street1 = broker['Address3Street1']
        db.address3Street2 = broker['Address3Street2']
        db.city3 = broker['City3']
        db.state3 = broker['State3']
        db.postalCode3 = broker['PostalCode3']
        db.country3 = broker['Country3']
        db.save
      end
    end
    @brokers=Broker.all
    render partial: 'brokers/refresh_broker'
  end

  def download_csv_broker
    require "csv"
    @brokers = Broker.all(:delete.ne => 1, :plan.ne => "lender", :lender.ne => 1)
    filename="brokers_"+Time.now.strftime("%m%d%y%H%M%S")
    save_path = Rails.root.join('csvs',filename+'.csv')
    CSV.open(save_path, "wb") do |csv|
      csv << ["Name", "Email", "Plan", "Phone", "City", "State"]
      @brokers.each do |broker|
        if broker.plan!= "lender"
          if !broker.plan.blank?
            bplan = broker.plan.capitalize
            if bplan == "Solo" || bplan == "Pro"
              bplan = "Free"
            end
          else
            bplan = ""
          end
          csv << [broker.name, broker.email, bplan, broker.phone1, broker.city, broker.state]
        end
      end
    end

    send_file 'csvs/'+filename+'.csv', :type => 'text/csv'
  end


  def refresh_broker
    @brokers=Broker.all
    render partial: 'brokers/refresh_broker'
  end


  def search
    srch = "/"+params['search']+"/"
    srch_string = params['search'].downcase
    @brkers = Broker.all(:delete.ne => 1, :plan.ne => "lender", :lender.ne => 1)
    
    @ids=Array.new
    unless @brkers.blank? 
      @brkers.each do |brokr|
        unless brokr.name.blank?
          name = brokr.name.downcase
          if name.include? srch_string
            @ids<<brokr.id  
          end
        end

        unless brokr.email.blank?
          email = brokr.email.downcase
          if email.include? srch_string
            @ids<<brokr.id 
          end
        end
      end
    end
    # abort("#{@ids.inspect}")
    
    
    @brokers=Broker.find(@ids)
    render partial: 'brokers/refresh_broker'
  end

  def delete_brokers
    ids=params[:moredata].split(",")
    require "stripe"
     Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"
    ids.each do |number|
      @brokerRecord=Broker.find(number)
      #abort("#{brokerRecord.inspect}")
      if !@brokerRecord.blank?
        user = User.find_by_email(@brokerRecord.email)
        unless user.blank? 
          @is_admin = ""
          user.roles.each do |role|
            if role.name == "Admin"
                @is_admin = "true"
            end
          end

          if @is_admin != "true"
            User.delete(user.id)
          end
          
          if defined? user.customer_id
            # if user.customer_id != nil
            #   cu = Stripe::Customer.retrieve(user.customer_id )
            #   cu.delete
            # end
          end

          if defined? user.with_recurly
            if user.with_recurly == 1
              account = Recurly::Account.find("#{user.id}")
              account.destroy
            end
          end
        end
        Broker.delete(@brokerRecord.id)
      end
      
   end 
   refresh_broker   
   flash.now[:notice] = "Brokers deleted successfully"
 end
  
  def show
    @broker = Broker.find(params['id'])
    user = User.find_by_email("#{@broker.email}")
    @loans = Loan.where(:email => @broker.email).all
    
    # brokers = Broker.all(:email_status => 1)

    # brokers.each do |brokr|
    #   bemail = brokr.email.downcase
    #   user = User.find_by_email("#{bemail}")
      
    #   unless user.blank?
    #     array_email = bemail.split("@")
    #     uname = array_email[0].gsub(' ','')
    #     sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
    #     user.username = sub_domain
    #     user.subdomain = sub_domain
    #     user.save
    #     # abort("#{user.inspect}")
    #   end
    # end
    # abort("#{user.inspect}")
  end

  def add
    
  end

  def settings
    if !current_user.blank?
      @user=User.find_by_id(current_user.id)
      # @user.name = "Kellen Jones"
      # @user.save
      @broker=Broker.find_by_email(current_user.email)
    else
      redirect_to "/users/sign_in"
    end
    
      
  end

  def check_account_type
    unless params[:request_access].blank?
       all_emails = params[:request_access].split(",")
       @nt_broker = ""
       all_emails.each do |email|
         bemail = email.delete(' ')
         check = Broker.find_by_email(bemail)
         if check.blank?
          if @nt_broker.blank?
            @nt_broker = "#{email}"
          else
            @nt_broker = "#{@nt_broker}, #{email}"
          end
         end
       end

      if @nt_broker.blank?
        render text: "true"
      else
        render text: "#{@nt_broker}"
      end
    end
  end
  
  def update
    if params[:is_broker] == "yes"
      @broker =  Broker.find_by_email(params[:email])
      @broker.name=params[:name]
      @broker.phone1=params[:phone1]
      unless params[:password].blank?
        @broker.password=params[:password]
      end
      unless params[:request_access].blank?
        @broker.request_access=params[:request_access]
      end
      @broker.save
    end

    @user = User.find_by_email(params[:email])
    @user.name = params[:name]
    @user.system_email = params[:system_email]
    @user.phone = params[:phone1]
    unless params[:password].blank?
      @user.password=params[:password]
      @user.user_password = params[:password]
    end
    @user.save
    
    unless params[:request_access].blank?
       all_emails = params[:request_access].split(",")
       all_emails.each do |email|
         bemail = email.delete(' ')
         check = Broker.find_by_email(bemail)
         unless check.blank?
            bId= @broker.id.to_s
            cId = check.id.to_s
            req_check = Request.first(:broker_id => bId, :subbroker_id => cId)
            if req_check.blank?
               req = Request.new
               req.broker_id = @broker.id
               req.subbroker_id = check.id
               req.save
               LoanUrlMailer.request_access(params[:email], check.id).deliver
             end
             unless req_check.blank?
               if req_check.status!=1
                LoanUrlMailer.request_access(params[:email], check.id).deliver
               end
             end
         end

       end

    end
    hostname = request.host

    unless params[:password].blank?
      redirect_to "http://#{hostname}/users/sign_in"
    else
      redirect_to action: 'settings'
    end

   end

  def allow_access
    req_check = Request.first(:broker_id => params[:broker_id], :subbroker_id => params[:sub_broker_id])
    req_check.status = 1
    req_check.save
  end

  def add_user
   if @infoBroker.parent_broker.blank?
        @user_id = current_user.id
        @user_email = current_user.email
    else
        @user_id = @infoBroker.parent_user
        @brokr = Broker.find_by_id(@infoBroker.parent_broker)
        @user_email = @brokr.email
    end
  end

  def check_email
    lenders = User.find_by_email(params[:email])
    if lenders.blank?
      @rsp = "yes"
    else
      @rsp = "no"
    end
    render plain: @rsp
  end

  def add_new_broker
    
    broker = Broker.new
    broker.firstName = params[:firstName]
    broker.lastName = params[:lastName]
    broker.name = params[:firstName]+' '+params[:lastName]
    broker.email = params[:email].gsub(' ','')
    broker.password = params[:password]
    broker.phone1 = params[:phone]
    broker.parent_user = params[:user_id]
    broker.plan = "free"
    broker.save

    user = User.new
    user.name = params[:firstName]+' '+params[:lastName]
    user.email = params[:email].gsub(' ','')
    user.password = params[:password]
    user.user_password = params[:password]
    roles = Array.new
    roles.push(Role.new(:name=>'Broker'))
    user.roles = roles
    usrname = params[:username].downcase
    user.username = usrname.gsub(' ','')
    uname = usrname.gsub(' ','')
    sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
    user.subdomain = sub_domain
    user.save
    LoanUrlMailer.login_credentials("#{user.id}", "Broker").deliver
    flash[:notice] = "Broker added successfully."
    redirect_to action: 'index'

  end

  def add_brokers
    brokerInfo = Broker.find_by_email(params[:user_email])
    brokerInfo.broker_admin = 1
    brokerInfo.save

    unless params[:permissions].blank?
      allow = params[:permissions].join(",")   
    end 
    
    broker = Broker.new
    broker.firstName = params[:firstName]
    broker.lastName = params[:lastName]
    broker.name = params[:firstName]+' '+params[:lastName]
    broker.email = params[:email]
    broker.phone1 = params[:phone1]
    broker.password = params[:password]
    broker.parent_broker = brokerInfo.id
    broker.parent_user = params[:user_id]
    unless params[:permissions].blank?
      broker.permissions = allow
    end
    broker.save

    user = User.new
    user.name = params[:firstName]+' '+params[:lastName]
    user.email = params[:email]
    user.password = params[:password]
    usrname = params[:username].downcase
    user.username = usrname.gsub(' ','')
    roles = Array.new
    roles.push(Role.new(:name=>'Broker'))
    user.roles = roles
    user.subdomain = current_user.subdomain
    user.plan = "free"
    user.max_users = "1"
    user.max_lenders = "5"
    user.max_storage = "1GB"
    user.max_upload = "10MB"
    user.pipelines = 0
    user.req_docs = 0
    user.loan_application_links = 0
    user.forward_email = 0
    user.save
   

    # abort("#{user.inspect}")
    LoanUrlMailer.login_credentials("#{user.id}", "sub broker").deliver
    flash[:notice] = "Broker added successfully."
    render text:"done"

  end

  def sub_brokers
    if @infoBroker.parent_user.blank?
       parent_id = current_user.id
       @brokers=Broker.all(:delete.ne => 1, :parent_user => current_user.id.to_s)
    else
        parent_id = @infoBroker.parent_broker
        @brokers=Broker.all(:delete.ne => 1, :parent_broker => @infoBroker.parent_broker.to_s, :id.ne => @infoBroker.id)
        @admins = Broker.all(:id => @infoBroker.parent_broker)
    end
    
    @canadd = "yes"
    # if @infoBroker.plan == "BUSINESS"
    #   numbrokers = Broker.count(:delete.ne => 1, :parent_user => parent_id.to_s)
    #   if numbrokers>=4
    #     @canadd = "no"
    #   end
    # elsif @infoBroker.plan == "ENTERPRISE"
    #   numbrokers = Broker.count(:delete.ne => 1, :parent_user => parent_id.to_s)
    #   if numbrokers>=14
    #     @canadd = "no"
    #   end
    # end

    numbrokers = Broker.count(:delete.ne => 1, :parent_user => parent_id.to_s)
    max_users = current_user.max_users.to_i - 1
    if numbrokers>=max_users
        @canadd = "no"
    end

  end

  def loans
     @broker = Broker.find_by_id(params[:id])
     @broker_id = params[:id]
     @loans = Loan.all(:email =>@broker.email, :delete.ne => 1, :archived.ne => true, :incomplete.ne => 1, :order => :id.desc)
  end

  def recent
       #################### Check Login #######################
  
    roles=current_user.roles
    @names = Array.new
    roles.each do |role|
      @names << role.name
    end
    @checkAdmin = @names.include?('Admin')
    @checkBroker = @names.include?('Broker')
    if @checkBroker!=true
     # authorize Loan
    end
    #
    @broker = Broker.find_by_id(params[:id])
    @loans = Loan.all(:email =>@broker.email, :delete.ne => 1, :archived.ne => true, :incomplete.ne => 1, :order => :id.desc)
    
     flash.now[:notice] = "Sorting by recent Loans"
     render partial: 'loans/all_loans'
  end


  def priority
      #################### Check Login #######################
    roles=current_user.roles
    @names = Array.new
    roles.each do |role|
      @names << role.name
    end
    @checkAdmin = @names.include?('Admin')
    @checkBroker = @names.include?('Broker')
    if @checkBroker!=true
     # authorize Loan
    end
    #################### End Check Login #######################

    @broker = Broker.find_by_id(params[:id])
    @loans = Loan.all(:email =>@broker.email, :delete.ne => 1, :archived.ne => true, :incomplete.ne => 1, :order => :sort_id.desc)
    
    flash.now[:notice] = "Sorting by priority"
    render partial: 'loans/sort_loans'
  end

  def changeorder
    @loan_ids=params[:moredata].split(",").map { |s| s.to_i }
    x=1
    @loan_ids.each do |number|
      loanRecord=Loan.find(number)
      loanRecord.sort_id=x
      loanRecord.save
      x += 1  
    end
    render nothing: true
  end

  def custom_search

    ###################################### Check User Role ################################################################
    roles=current_user.roles
    @names = Array.new
    roles.each do |role|
      @names << role.name
    end
    @checkAdmin = @names.include?('Admin')
    @checkBroker = @names.include?('Broker')
    
    ###################################### End Check User ##################################################################
    
    ###################################### Fetch Loans #####################################################################
    
    broker = Broker.find_by_id(params[:broker_id])
    all_loans=Loan.all(:email => broker.email)
    
    ###################################### Fetch Loans End #####################################################################

    by_loanmin = Array.new
    state_id = Array.new
    loan_cat = Array.new 
    loan_type = Array.new
    custom_search = Array.new
    type = ""
    all_loans.each do |loan|
      
      ####################################################### Loan Value #################################################
      if  params['loanMaxDropDown'].to_i>0 
       if defined? loan.info['_NetLoanAmountRequested0']
          if loan.info['_NetLoanAmountRequested0'].to_i>=params['loanMinDropDown'].to_i &&  loan.info['_NetLoanAmountRequested0'].to_i<=params['loanMaxDropDown'].to_i
             by_loanmin << loan.id
          end
        end
      end

      if params['loanMaxDropDown'].to_i==0
          if defined? loan.info['_NetLoanAmountRequested0']
            if loan.info['_NetLoanAmountRequested0'].to_i>=params['loanMinDropDown'].to_i
             by_loanmin << loan.id
            end 
          end
      end

      ####################################################### Loan Value End ################################################
    
      ###################################################### States ##########################################################
      unless params['State3'].blank?
        if defined? loan.info['State3']
          params['State3'].each do |state|
              if loan.info['State3']==state
                  state_id<<loan.id
              end
          end   
        end
      end
      ###################################################### States End ######################################################
      
      ###################################################### Lending Category ################################################
      
       unless params['lendingCategory'].blank?
        if defined? loan.info['_LendingCategory']
          if loan.info['_LendingCategory'] == params['lendingCategory']
              loan_cat << loan.id
          end
        end
       end

      ###################################################### Lending Category End ################################################
      
      ###################################################### Lending Type ########################################################
        
       unless params['lendingTypes'].blank?
        type = "yes"
        if defined? loan.info['_LendingTypes']
          unless loan.info['_LendingTypes'].blank?
            #lending_types = loan.info['_LendingTypes'].split(",")
            if loan.info['_LendingTypes'] == params['lendingTypes']
                loan_type << loan.id
            end
          end
        end
     end


     unless params['businessFinancingTypes'].blank?
        type = "yes"
         if defined? loan.info['_BusinessFinancingTypes']
          unless loan.info['_BusinessFinancingTypes'].blank?
            #business_types = loan.info['_BusinessFinancingTypes'].split(",")
              if loan.info['_BusinessFinancingTypes'] == params['businessFinancingTypes']
                loan_type << loan.id
            end
          end
        end
     end
     unless params['equityandCrowdFunding'].blank?
        type = "yes"
        if defined? loan.info['_EquityandCrowdFunding']
          unless loan.info['_EquityandCrowdFunding'].blank?
          #lending_types = loan.info['_EquityandCrowdFunding'].split(",")
            if loan.info['_EquityandCrowdFunding'] == params['equityandCrowdFunding']
                loan_type << loan.id
            end
          end
        end
     end
     unless params['mortageTypes'].blank?
        type = "yes"
        if defined? loan.info['_MortageTypes']
          unless loan.info['_MortageTypes'].blank?
            #lending_types = loan.info['_MortageTypes'].split(",")
            if loan.info['_MortageTypes'] == params['mortageTypes']
                loan_type << loan.id
            end
          end
        end
     end

      ###################################################### Lending Type End ####################################################
    end 
      custom_search[0] = by_loanmin 

      unless params['State3'].blank?
        if params['State3'][0].blank?
          custom_search[1] = by_loanmin
        else
          custom_search[1] = state_id 
       end
      else
        custom_search[1] = by_loanmin
      end

      unless params['lendingCategory'].blank?
        if params['lendingCategory'] == "all"
            custom_search[2] = by_loanmin
        else
            custom_search[2] = loan_cat
        end
        
      end

      if type=="yes"
        custom_search[3] = loan_type 
      end
     # abort("#{custom_search.inspect}")

    
    select = custom_search
   # custom_search.each do |search|
    #  unless search.blank?
     #    select<<search  
     # end
    #end

    num = select.count 
    
    if num==1
      ids = select[0]
    elsif num==2
      ids = select[0]&select[1]
    elsif num==3
      ids = select[0]&select[1]&select[2]
    else
      ids = select[0]&select[1]&select[2]&select[3]
    end
   ########################################### Check Sorting ##############################################
   if params['sorting'] == "recent"
      @loans_record = Loan.find(ids)
      if @loans_record.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans=@loans_record.reverse { |k| k['id'] }
      end
      flash.now[:notice] = "Sorting by recent Loans"
      render partial: 'loans/all_loans'
   else
      @loans_record = Loan.find(ids)
      if @loans_record.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans=@loans_record.sort_by { |k| k['sort_id'] }
      end
      flash.now[:notice] = "Sorting by priority"
      render partial: 'loans/sort_loans'
   end
   ########################################### Check Sorting End ##############################################
  end
  
  def edit_user
    @broker = Broker.find_by_id(params[:id])
  end
  
  def edit_broker
    
    broker = Broker.find_by_id(params[:broker_id])
    broker.firstName = params[:firstName]
    broker.lastName = params[:lastName]
    broker.name = params[:firstName]+' '+params[:lastName]
    broker.email = params[:email]
    broker.phone1 = params[:phone1]
    unless params[:password].blank?
      broker.password = params[:password]
    end
    unless params[:permissions].blank?
      allow = params[:permissions].join(",")
      broker.permissions = allow
    end
    broker.save

    user = User.find_by_email(params[:email])
    user.name = params[:firstName]+' '+params[:lastName]
    user.email = params[:email]
    unless params[:password].blank?
      user.password = params[:password]
    end
    unless user.subdomain.blank?
       user.subdomain = current_user.subdomain
    end
    user.save

    flash[:notice] = "Broker edited successfully."
    render text:"done"

  end


  def change_password

    @broker = Broker.find_by_id(params[:id])
  end

  def edit_password

    broker = Broker.find_by_id(params[:id])
    #abort("#{broker.inspect}")
    unless params[:password].blank?
      broker.password = params[:password]
    end
    broker.save

    user = User.find_by_email(params[:email])
    user.email = params[:email]
    unless params[:password].blank?
      user.password = params[:password]
    end
    user.save

    flash[:alert] = "Password has been changed successfully."
    redirect_to action: 'sub_brokers'

  end

  def config_account

    uri = URI.parse("https://www.idealsuite.com/index.php?r=loanflow/registration/checkuserexistance/")

    # Shortcut
    #response = Net::HTTP.post_form(uri, {"user[name]" => "testusername", "user[email]" => "testemail@yahoo.com"})


    # Full control
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"user_email" => params[:email]})
    response = http.request(request)
    username = response.body

    if username != "no"
      usr = User.find_by_id("#{current_user.id}")
      usr.ids_config = 1
      usr.ids_username = username
      usr.save
      
      @output="done"
    else
      @output="no"
    end

    render text: "#{@output}"

  end

  def checkids
    # formData = params[:ids]

    uri = URI.parse("https://idealsuite.com/index.php?r=user/login/loginapi")

    # Shortcut
    #response = Net::HTTP.post_form(uri, {"user[name]" => "testusername", "user[email]" => "testemail@yahoo.com"})


    # Full control
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"UserLogin[username]" => params[:username], "UserLogin[password]" => params[:password]})
    response = http.request(request)
    username = response.body

    if username != "no"
      usr = User.find_by_id("#{current_user.id}")
      usr.ids_config = 1
      usr.ids_username = username
      usr.save
      
      @output="done"
    else
      @output="no"
    end

    render text: "#{@output}"

  end

  def credit_api
   # resp = HTTParty.post('https://demo.mortgagecreditlink.com/inetapi/AU/get_credit_report.aspx', :query => {:userID => 1024}, :body => 'xml' )
    require 'json'
    @request_time = "2016-09-20T22:46:07"
    xmlval = '<REQUEST_GROUP MISMOVersionID="2.3.1">
                  <SUBMITTING_PARTY _Name="Idealview" _Identifier="TestSubmittingPartyID">
                  <PREFERRED_RESPONSE _Format="Other" _FormatOtherDescription="HTML"></PREFERRED_RESPONSE>
                  </SUBMITTING_PARTY>
                  <REQUEST RequestDatetime="2016-09-20T22:46:07" InternalAccountIdentifier="" LoginAccountIdentifier="FundingDB" LoginAccountPassword="246845wd">
                  <REQUEST_DATA>
                  <CREDIT_REQUEST MISMOVersionID="2.3.1" LenderCaseIdentifier="lender_57e8ab87ab608a0f39000006" RequestingPartyRequestedByName="idvServicer">
                  <CREDIT_REQUEST_DATA CreditRequestID="idv_request_57e90e44ab608a0f39000017" BorrowerID="idv_b_57e8ab87ab608a0f39000006" CreditReportIdentifier="" CreditReportRequestActionType="Submit" CreditReportType="Merge" CreditRequestDateTime="2016-09-20T22:46:07" CreditRequestType="Individual">
                            <CREDIT_REPOSITORY_INCLUDED _EquifaxIndicator="Y" _ExperianIndicator="Y" _TransUnionIndicator="Y"></CREDIT_REPOSITORY_INCLUDED>
                          </CREDIT_REQUEST_DATA>
                          <SERVICE_PAYMENT _AccountIdentifier="4000000000000001" _AccountHolderName="JOHN Q PUBLIC" _AccountHolderStreetAddress="123 MAIN ST" _AccountHolderCity="ANYTOWN" _AccountHolderState="CA" _AccountHolderPostalCode="12345" _AccountExpirationDate="2012-05-12" _SecondaryAccountIdentifier="123">
                           </SERVICE_PAYMENT>
                          <LOAN_APPLICATION>
                             <BORROWER BorrowerID="idv_b_57e8ab87ab608a0f39000006"  _FirstName="Wayne" _MiddleName="" _LastName="Nehwadowich" _NameSuffix="" _AgeAtApplicationYears="" _PrintPositionType="Borrower" _SSN="000000001" MaritalStatusType="NotProvided">
            <_RESIDENCE _StreetAddress="178 Forestburgh Road" _City="Monticello" _State="NY" _PostalCode="12701" BorrowerResidencyType="Current"></_RESIDENCE>
          </BORROWER>
                          </LOAN_APPLICATION>
                        </CREDIT_REQUEST>
                      </REQUEST_DATA>
                    </REQUEST>
                </REQUEST_GROUP>'
# abort("#{xmlval}")
   # result =  Hash.from_xml(xmlval)
   # resp = HTTParty.post('https://demo.mortgagecreditlink.com/inetapi/AU/get_credit_report.aspx', :query => result, :body => 'xml' )
    headers = {"Content-Type" => "application/xml"}
    uri = URI.parse("https://demo.mortgagecreditlink.com/inetapi/AU/get_credit_report.aspx");
     
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    
    request = Net::HTTP::Post.new(uri.request_uri)
    data = xmlval
    # jdata = data.to_json
    response = http.post(uri.path, data, headers)
    # rsp = response.body
    rsp = response.body

    # doc  = Nokogiri::XML(rsp)
    # xslt = Nokogiri::XSLT(xsl)
    # out  = xslt.transform(doc)

    # puts out.to_xml
    result =  Hash.from_xml(rsp)
    # abort("#{result.inspect}")
    # objArray = JSON.parse(rsp)
    # abort("#{rsp.inspect}")
    # html_resp = result["RESPONSE_GROUP"]["RESPONSE"]["RESPONSE_DATA"]["CREDIT_RESPONSE"]["EMBEDDED_FILE"]["DOCUMENT"]
    status = result["RESPONSE_GROUP"]["RESPONSE"]["STATUS"]["_Description"]
    if status == "READY"
      html_resp = result["RESPONSE_GROUP"]["RESPONSE"]["RESPONSE_DATA"]["CREDIT_RESPONSE"]["EMBEDDED_FILE"]["DOCUMENT"]
    end
    render text: html_resp
  end


  def delete_subbroker
   
    ids=params[:moredata].split(",")
    require "stripe"
     Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"
    ids.each do |number|
      brokerRecord=Broker.find(number)
      #abort("#{brokerRecord.inspect}")
      user = User.find_by_email(brokerRecord.email)
      unless user.blank? 
        User.delete(user.id)
        if defined? user.customer_id
          if user.customer_id != nil
            cu = Stripe::Customer.retrieve(user.customer_id )
            cu.delete
          end
        end

        if defined? user.with_recurly
          if user.with_recurly == 1
            account = Recurly::Account.find("#{user.id}")
            account.destroy
          end
        end
      end
      Broker.delete(brokerRecord.id)
   end 
    render text:"done"
  end


end
