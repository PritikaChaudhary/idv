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
        
         #abort("#{string}")
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
              @user.name = broker['FirstName']+' '+broker['LastName']
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
    @brokers=Broker.all(:delete.ne => 1)
    #abort("#{@brokers.inspect}")
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

  def refresh_broker
    @brokers=Broker.all
    render partial: 'brokers/refresh_broker'
  end


  def search
    srch = "/"+params['search']+"/"
    @brkers = Broker.all(name: /#{params['search']}/)
    @ids=Array.new
    @brkers.each do |brker|
      @ids<<brker.id
    end
    @brokrs = Broker.all(email: /#{params['search']}/)
    @brokrs.each do |brokr|
      @ids<<brokr.id
    end
    
    @brokers=Broker.find(@ids)
    render partial: 'brokers/refresh_broker'
  end

  def delete_brokers
    ids=params[:moredata].split(",")
    ids.each do |number|
      brokerRecord=Broker.find(number)
      #abort("#{brokerRecord.inspect}")
      brokerRecord.delete=1
      brokerRecord.save
    end 
   refresh_broker   
   flash.now[:notice] = "Brokers deleted successfully"
 end
  
  def show
    @broker = Broker.find(params['id'])
    @loans = Loan.where(:email => @broker.email).all
    #abort("#{@loans.inspect}")
  end

  def add
    
  end

  def settings
      @user=User.find_by_id(current_user.id)
      @broker=Broker.find_by_email(current_user.email)
      #abort("#{current_user.email}")
  end

  def update
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

    unless params[:password].blank?
      @user = User.find_by_email(params[:email])
      @user.password=params[:password]
      @user.save
    end
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
    unless params[:password].blank?
      redirect_to "http://dash.idealview.us/users/sign_in"
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

  def add_broker
    
    brokerInfo = Broker.find_by_email(params[:user_email])
    brokerInfo.broker_admin = 1
    brokerInfo.save

    allow = params[:permissions].join(",")
    broker = Broker.new
    broker.firstName = params[:firstName]
    broker.lastName = params[:lastName]
    broker.name = params[:firstName]+' '+params[:lastName]
    broker.email = params[:email]
    broker.phone1 = params[:phone1]
    broker.password = params[:password]
    broker.parent_broker = brokerInfo.id
    broker.parent_user = params[:user_id]
    broker.permissions = allow
    broker.save

    user = User.new
    user.name = params[:firstName]+' '+params[:lastName]
    user.email = params[:email]
    user.password = params[:password]
    roles = Array.new
    roles.push(Role.new(:name=>'Broker'))
    user.roles = roles
    user.save

    flash[:alert] = "Broker added successfully."
    redirect_to action: 'sub_brokers'

  end

  def sub_brokers
    if @infoBroker.parent_user.blank?
       @brokers=Broker.all(:delete.ne => 1, :parent_user => current_user.id.to_s)
    else
        @brokers=Broker.all(:delete.ne => 1, :parent_broker => @infoBroker.parent_broker.to_s, :id.ne => @infoBroker.id)
        @admins = Broker.all(:id => @infoBroker.parent_broker)

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
    allow = params[:permissions].join(",")
    broker = Broker.find_by_id(params[:broker_id])
    broker.firstName = params[:firstName]
    broker.lastName = params[:lastName]
    broker.name = params[:firstName]+' '+params[:lastName]
    broker.email = params[:email]
    broker.phone1 = params[:phone1]
    unless params[:password].blank?
      broker.password = params[:password]
    end
    broker.permissions = allow
    broker.save

    user = User.find_by_email(params[:email])
    user.name = params[:firstName]+' '+params[:lastName]
    user.email = params[:email]
    unless params[:password].blank?
      user.password = params[:password]
    end
    user.save

    flash[:alert] = "Broker edited successfully."
    redirect_to action: 'sub_brokers'

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

end
