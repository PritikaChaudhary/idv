class LoansController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'

  skip_before_action :verify_authenticity_token, :only => :post_new_loan
  before_action :verify_custom_authenticity_token, :only => :post_new_loan



 def index

   # redirect_to "https://fundingdatabase.com"

   # cookies[:send_fd] = "true"
   # abort("#{cookies[:send_fd]}")
    @terms = TermCondition.find_by_type("shop_loans")
   #################### Create Broker  ######################
    @loans = Loan.all
    @emails = Array.new
    binfo = Array.new
   @loans.each do |loan|
      if defined? loan.info['Email']
        @emails << loan.info['Email']
      end
   end
   all_emails=Array.new
  
   @emails.each do |email|
      unless email.blank?
        @numbr= ""
        @numbr = @emails.count(email) 
        @i=0
        if @numbr > 1
        information = Loan.find_by_email(email)
          check = Broker.find_by_email(email)
              
            if check.blank?
              all_emails<<email
              pas_string = (0...8).map { (65 + rand(26)).chr }.join
              #abort("#{information.inspect}")
              broker = Broker.new
              unless information.info.blank?
                 unless information.info['FirstName'].blank?
                   broker.name = information.info['FirstName']
                 end
              end
              broker.email = email
              broker.password = pas_string
              broker.save
              #abort("#{broker.inspect}")
              @userInfo = User.find_by_email(email)
                if @userInfo.blank?
                    @user = User.new
                    authorize @user
              @roles = Array.new
                    @roles.push(Role.new(:name=>'Broker'))
              @user.roles = @roles
                    if defined? information['FirstName']
                      @user.name = information['FirstName']
                    end
                    @user.email = email
                    @user.password = pas_string
                    @user.save
                    #abort("#{@user.inspect}")
                    LoanUrlMailer.email_broker(broker).deliver
                    broker.email_status = 1
                    broker.save
                else
                  @roles = @userInfo.roles
          
              @names = Array.new
              @roles.each do |role|
                @names = role['name']
              end

              check_broker = @names.include? 'Broker'
              if check_broker==false
                 @roles.push(Role.new(:name=>'Broker'))
                 @userInfo.roles=@roles
                 @userInfo.save
              end

              end
              @i +=1
            end
          check = ""
        end
    end
     
    end
    #abort("#{all_emails.inspect}")
    
    #################### End Broker Create ##################

    #################### Check Login #######################
    roles=current_user.roles
    @names = Array.new
    roles.each do |role|
      @names << role.name
    end
    @checkAdmin = @names.include?('Admin')
    @checkBroker = @names.include?('Broker')
    if @checkBroker!=true
      authorize Loan
    end
    #################### End Check Login #######################

    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      #abort("#{reqs}")
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
          unless broker_req.blank?
            @broker_emails << broker_req['email']
         end
        end
      end
      @total_loans = Loan.count(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :per_page => 10, :page => params[:page], :total_entries => @total_loans, :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
      @total_loans = Loan.count(:delete.ne => 1, :archived.ne => true) 
      @loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :per_page => 10, :page => params[:page], :total_entries => @total_loans, :order => :id.desc)
      # @loans = Loan.all
      # @loans = Loan.find_by_id(4222)
      # abort("#{@loans.inspect}")
    end
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
    end

    @partition = @total_loans/ 10
    @partitions = @partition.round
    @check = @partition*10
    if @check<@total_loans
      @partitions = @partition + 1
    end
    @records = 10
    @page = 1

   #  @loans.each do |dloan|
   #    if dloan.created_by_info.blank?
   #      dloan.created_by_info = "Admin"
   #      dloan.save
   #    end
        
   #  end

   # abort("Done")
 end
  
  
  
  def temp
    # @loans = Infusionsoft.data_query('Contact',1000,0,{:ContactType=>'Borrower'},Loan.highlight_fields) 
    @loans = Loan.all
    @output=Array.new
    @loans.each do |loan|
      loan.images.each do |temp|
        temp.delete
      end
      image_keys = loan.get_s3_images
      if !image_keys.blank?
        if image_keys.first.is_a?(String)
          @output<<image_keys
          image_keys.each do |key|
              check = Image.find_by_file_id(key)
              file_name = key.gsub(loan.id.to_s+'/', '')
              if !check.blank? && check.url.blank?
                dbImage = check
                dbImage.file_id = key_name
                dbImage.name = file_name
                dbImage.url = "https://s3-us-west-2.amazonaws.com/#{S3_BUCKET_NAME}/#{loan.id}/#{file_name}"
                dbImage.src = ''
                dbImage.data = ''
              
              else 
                  dbImage = Image.new(
                                :loan_id=>loan.id,
                                :file_id=>key, 
                                :name=>file_name, 
                                :url=>"https://s3-us-west-2.amazonaws.com/#{S3_BUCKET_NAME}/#{loan.id}/#{file_name}"
                                ) 
              end  
              dbImage.save           
          end
          
          

          
          
        end
      end
    end

  end

  def hide_borrower

    borrower = Borrower.find_by_id(params[:id])
    # abort("#{borrower.inspect}")
    borrower.hide = 1
    borrower.save

    render text: "done"
  
  end

  def hide_borrower_field


    rplc = "_#{params[:id]}"
    field_name = params[:field].gsub! rplc, ''
     
    borrower = Borrower.find_by_id(params[:id])
    # abort("#{borrower.hide_fields}")
    if borrower.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{borrower.hide_fields}, #{params[:field]}"
    end
    
    borrower.hide_fields = fields
    
    borrower.save

    render text: "done"

  end

  def show_borrower_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    borrower = Borrower.find_by_id(params[:id])
    fname = "#{params[:field]}, "
    
    unless borrower.hide_fields.blank?
      fields = borrower.hide_fields.gsub! fname, ''
    end
    
    borrower.hide_fields = fields
    
    borrower.save

    render text: "done"
  end

  def hide_copyborrower_field


    rplc = "_#{params[:id]}"
    field_name = params[:field].gsub! rplc, ''
     
    borrower = CopyBorrower.find_by_id(params[:id])
    # abort("#{borrower.hide_fields}")
    if borrower.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{borrower.hide_fields}, #{params[:field]}"
    end
    
    borrower.hide_fields = fields
    
    borrower.save

    render text: "done"

  end

  def show_copyborrower_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    borrower = CopyBorrower.find_by_id(params[:id])
    fname = "#{params[:field]}, "
    
    unless borrower.hide_fields.blank?
      fields = borrower.hide_fields.gsub! fname, ''
    end
    
    borrower.hide_fields = fields
    
    borrower.save

    render text: "done"
  end

  def hide_collateral_field


    rplc = "_#{params[:id]}"
    field_name = params[:field].gsub! rplc, ''
     
    collat = Collateral.find_by_id(params[:id])
    # abort("#{borrower.hide_fields}")
    if collat.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{collat.hide_fields}, #{params[:field]}"
    end
    
    collat.hide_fields = fields
    
    collat.save

    render text: "done"

  end

  def show_collateral_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    collat = Collateral.find_by_id(params[:id])
    fname = "#{params[:field]}, "
    
    unless collat.hide_fields.blank?
      fields = collat.hide_fields.gsub! fname, ''
    end
    
    collat.hide_fields = fields
    
    collat.save

    render text: "done"
  
  end
  
  def hide_loan_field

    @loan = Loan.find_by_id(params[:id].to_i)
    # abort("#{borrower.hide_fields}")
    if @loan.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{@loan.hide_fields}, #{params[:field]}"
    end
    
    @loan.hide_fields = fields
    @loan.save

    render text: "done"

  end


  def show_loan_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    @loan = Loan.find_by_id(params[:id].to_i)
    fname = "#{params[:field]}, "
    
    unless @loan.hide_fields.blank?
      fields = @loan.hide_fields.gsub! fname, ''
    end
    
    @loan.hide_fields = fields
    
    @loan.save

    render text: "done"
  
  end

   def hide_copyloan_field

    @loan = CopyLoan.find_by_id(params[:id])
    # abort("#{borrower.hide_fields}")
    if @loan.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{@loan.hide_fields}, #{params[:field]}"
    end
    
    @loan.hide_fields = fields
    @loan.save

    render text: "done"

  end


  def show_copyloan_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    @loan = CopyLoan.find_by_id(params[:id])
    fname = "#{params[:field]}, "
    
    unless @loan.hide_fields.blank?
      fields = @loan.hide_fields.gsub! fname, ''
    end
    
    @loan.hide_fields = fields
    
    @loan.save

    render text: "done"
  
  end

  def hide_copycollateral_field


    rplc = "_#{params[:id]}"
    field_name = params[:field].gsub! rplc, ''
     
    collat = CopyCollateral.find_by_id(params[:id])
    # abort("#{borrower.hide_fields}")
    if collat.hide_fields.blank?
      fields = params[:field]
    else
      fields = "#{collat.hide_fields}, #{params[:field]}"
    end
    
    collat.hide_fields = fields
    
    collat.save

    render text: "done"

  end

  def show_copycollateral_field
    # rplc = "_#{params[:id]}"
    # field_name = params[:field].gsub! rplc, ''
    
    collat = CopyCollateral.find_by_id(params[:id])
    fname = "#{params[:field]}, "
    
    unless collat.hide_fields.blank?
      fields = collat.hide_fields.gsub! fname, ''
    end
    
    collat.hide_fields = fields
    
    collat.save

    render text: "done"
  
  end


  def show_borrower
    borrower = Borrower.find_by_id(params[:id])
    # abort("#{borrower.inspect}")
    borrower.hide = 0
    borrower.save

    render text: "done"
  end

  def hide_collateral
    collateral = Collateral.find_by_id(params[:id])
    # abort("#{borrower.inspect}")
    collateral.hide = 1
    collateral.save

    render text: "done"
  end
  
  def show_collateral
    collateral = Collateral.find_by_id(params[:id])
    # abort("#{borrower.inspect}")
    collateral.hide = 0
    collateral.save

    render text: "done"
  end


  def show
    # mycookie = cookies[:user_name]
    # abort("#{mycookie}")


    if current_user.blank?
      flash[:alert] ='Please login to access this page.'
      redirect_to '/'
      return
    end


    @terms = TermCondition.find_by_type("shop_loans")
   # docs = Document.all(:order => :id.asc)
   # abort("#{docs.inspect}")
    #abort("#{@bucketName}") 
  #  bucket = S3.create_bucket(bucket: 'testbusketxyz')
   loan_url = LoanUrl.find_by_url(params[:id])
     
   

    if loan_url
      @loan = loan_url.loan
      #abort("#{@loan}")
      if loan_url.visits.blank?
        loan_url.visits = Array.new
      end
      loan_url.visits<<Time.now.getutc
      #loan_url.save
      redirect_to action: 'detail', id: params[:id]
    end

    if @loan.blank? && !current_user.blank?
      @loan = Loan.find_by_id(params[:id].to_i)
      @num_of_loans = LoanUrl.all(:loan_id => params[:id].to_i)
      @num =  @num_of_loans.count
    end
    # abort("#{@loan.inspect}")
    @cloan = CopyLoan.find_by_loan_id(@loan.id)
    ########################### Matching Lenders ##########################################

    info = Array.new
    linfo = Array.new

    
        lenders = Lender.where(:loanMinDropDown.lte => @loan.info['_NetLoanAmountRequested0'].to_i,  :lendingCategory => /#{@loan.info['_LendingCategory']}/, :lendingStates0 => /#{@loan.info['State3']}/).fields(:company, :loanMinDropDown, :lendingTypes, :lendingStates0).all
        # abort("#{lenders.inspect}")
        if !lenders.blank?
          lenders.each do |lender|
            linfo << lender.id
          end
        end

        if !@loan.info['_NetLoanAmountRequested0'].blank?
          mlenders = Lender.where(:loanMaxDropDown.ne=>nil).fields(:company, :loanMaxDropDown).all
          if !mlenders.blank?
              mlenders.each do |mlender|
                if mlender.loanMaxDropDown!="No Max"
                  max = mlender.loanMaxDropDown.to_i
                  if max > @loan.info['_NetLoanAmountRequested0'].to_i
                    info << mlender.id
                  end
                else
                  info << mlender.id
                end
              end
          end 
        else
          info = linfo
        end
        # abort("#{linfo.inspect}")            
        if !linfo.blank? && !info.blank?
          ids = linfo&info
          @allenders = Lender.all(:id => ids)
        else
          @allenders = Array.new        
        end
        @numOfLenders = @allenders.count
        # abort("#{@numOfLenders}")
    ########################### End Matching Lenders ######################################

     uInfo = User.find_by_id(@loan.info['added_by'])
     if !uInfo.blank?
        
       if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

          @bucketName = uInfo.bucket_name
          resp = S3.list_objects(bucket: "#{@bucketName}")
          @bucket_size = 0
          resp.contents.each do |object|
            @bucket_size = @bucket_size+object.size
          end
          if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
            #@max_size = 10022482
            @max_size = 1073741824
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
            
            @max_size = 5368709120
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          else
            @fileUpload = "true"
          end
        else
            @bucketName = S3_BUCKET_NAME
            @fileUpload = "true"
        end
      else
        uInfo = User.find_by_email(@loan.email)
        if !uInfo.blank?
          if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

          @bucketName = uInfo.bucket_name
          resp = S3.list_objects(bucket: "#{@bucketName}")
          @bucket_size = 0
          resp.contents.each do |object|
            @bucket_size = @bucket_size+object.size
          end
          if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
            #@max_size = 10022482
            @max_size = 1073741824
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
            
            @max_size = 5368709120
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          else
            @fileUpload = "true"
          end
        else
            @bucketName = S3_BUCKET_NAME
            @fileUpload = "true"
        end
        end
      end

      if !@adminLogin.blank?
          @fileUpload = "true"
      end



    if @loan.blank?
      flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
      redirect_to '/'
      return
    end
     dateField = ['_ExpectedCloseDate', '_AppraisalDate', 'Birthday', 'DateCreated', 'LastUpdated']
    if @loan.blank?
      begin
        # contact = infusionsoft.data_load('Contact', params[:id], Loan.all_fields)
      rescue Exception
        flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
        redirect_to '/'
        return;
      end
        
      if contact['_LoanName'].blank?
        contact['_LoanName'] = 'Your Awesome Loan Name Here'
      end 
      
      dateField.each do |field|
        temp = contact[field]
        if !temp.blank?
          contact[field]=temp.year.to_s+'-'+temp.month.to_s+'-'+temp.day.to_s
        end
      end

      @loan = Loan.new
      @loan.name=contact['_LoanName']
      @loan._id = contact['Id']
      @loan.info = contact
      @images = @loan.images
      @documents = @loan.get_docs
      if @loan.info['maturity_date']=="0000-00-00" 
        @loan.info['maturity_date'] = ""
      end
      @loan.save()
    
    else
      @images = @loan.images
      @documents = @loan.get_docs
      if @loan.info['maturity_date']=="0000-00-00" 
        @loan.info['maturity_date'] = ""
      end
     
       @loan.save()
    
    end
   @folders = CustomFolder.all(:loan_id => @loan.id.to_i)
   # @files= Image.all(:order=> :id.asc)
   # abort("#{@loan.inspect}")
   @borrowers = Borrower.all(:loan_id => @loan.id)
    # abort("#{@borrowers.inspect}")
  @brwrId = Array.new
  @brwrId << "loan_highlight"
  @brwrId << "loc_location"
  unless @borrowers.blank?

    @borrowers.each do |borrower|
       @brwrId << "personal_loc_#{borrower.id}"
       @brwrId << "business_loc_#{borrower.id}"
       @brwrId << "guarantor_loc_#{borrower.id}"
       if @loan.email.blank?
          if borrower.borrower_guarantor == "Yes" 
             unless borrower.personal_email.blank?
                @loan.email = borrower.personal_email
                @loan.info['Email'] = borrower.personal_email
                @loan.info['FirstName'] = borrower.personal_name
                @loan.info['Phone'] = borrower.personal_phone
                @loan.save
             end
          end
       end
    end
  end

  # abort("#{@loan.total_primary_sf}")
  # abort("#{noi_ytd} #{noi_ytd_arr.inspect}")
  @collaterals = Collateral.all(:loan_id => @loan.id)
    collateral_acres = 0
    collateral_secondarysize = 0
    collateral_total_gross = 0
    noi_ytd = 0

    acres = Array.new
    sq_footage = Array.new
    gross = Array.new
    noi_ytd_arr = Array.new

    gross_table=0
    noi_table = 0
    acre_table=0 
    footage_table=0

  unless @collaterals.blank?
    @collaterals.each do |collateral|
      @brwrId << "collateral_loc_#{collateral.id}"
      
      unless collateral.gross_monthly_income.blank?
        gross << collateral.gross_monthly_income
        gross_num = CollateralGross.find_by_collateral_id(collateral.id.to_s)
        
        if gross_num.blank?
          gross_val = CollateralGross.new 
          gross_val.value = collateral.gross_monthly_income.to_f
          gross_val.collateral_id = collateral.id
          gross_val.loan_id = collateral.loan_id
          gross_val.save

          @loan.info['created_date_gross'] = @loan.created_date
          @loan.save

          gross_table=1
        end
        collateral_total_gross += collateral.gross_monthly_income.to_f
      end

      unless collateral.noi_ytd.blank?
        noi_ytd_arr << collateral.noi_ytd
        noi_num = CollateralNoi.find_by_collateral_id(collateral.id.to_s)

        if noi_num.blank?
          noi_val = CollateralNoi.new 
          noi_val.value = collateral.noi_ytd.to_f
          noi_val.collateral_id = collateral.id
          noi_val.loan_id = collateral.loan_id
          noi_val.save

          @loan.info['created_date_noi'] = @loan.created_date
          @loan.save
          
          noi_table = 1
        end
        noi_ytd += collateral.noi_ytd.to_f
      end
      
      if collateral.size=="Acres"
        acres << collateral.acres
        acres_num = CollateralAcres.find_by_collateral_id(collateral.id.to_s)
        
        if acres_num.blank?
          acres_val = CollateralAcres.new 
          acres_val.value = collateral.acres.to_f
          acres_val.collateral_id = collateral.id
          acres_val.loan_id = collateral.loan_id
          acres_val.save
          acre_table = 1
        end
        collateral_acres += collateral.acres.to_f
        collateral.sq_footage=""
        collateral.save

        footage_acre = CollateralSqfootage.find_by_collateral_id(collateral.id.to_s)
        if footage_acre.blank?
          footage_val = CollateralSqfootage.new
          footage_val.value = collateral.acres.to_f * 43560
          footage_val.collateral_id = collateral.id
          footage_val.loan_id = collateral.loan_id
          footage_val.save
          footage_table=1
        else
          old_val = footage_acre.value.to_f
          new_val = collateral.acres.to_f * 43560
          footage_acre.value = old_val + new_val
          footage_acre.collateral_id = collateral.id
          footage_acre.loan_id = collateral.loan_id
          footage_acre.save
          footage_table=1
        end
        add_this = collateral.acres.to_f * 43560
        collateral_secondarysize += add_this

      end

      unless collateral.structural_size.blank?
        if collateral.structural_size == "Units" 
          unless collateral.sf_per_unit.blank? 
            footage_unit = CollateralSqfootage.find_by_collateral_id(collateral.id.to_s)
            if footage_unit.blank?
              footage_val = CollateralSqfootage.new
              footage_val.value = collateral.units.to_f * collateral.sf_per_unit.to_f
              footage_val.collateral_id = collateral.id
              footage_val.loan_id = collateral.loan_id
              footage_val.save
              footage_table=1
              add_this = collateral.units.to_f * collateral.sf_per_unit.to_f
              collateral_secondarysize += add_this
            else
              old_val = footage_unit.value.to_f
              new_val = collateral.units.to_f * collateral.sf_per_unit.to_f
              footage_unit.value = old_val + new_val
              footage_unit.collateral_id = collateral.id
              footage_unit.loan_id = collateral.loan_id
              footage_unit.save
              footage_table=1
              add_this= old_val + new_val
              collateral_secondarysize += add_this
            end
            collateral.structural_sq_footage=""
            collateral.save
          end 
        elsif collateral.structural_size == "Sq Footage"
           st_footage = CollateralSqfootage.find_by_collateral_id(collateral.id.to_s)
            if st_footage.blank?
              footage_val = CollateralSqfootage.new
              footage_val.value = collateral.structural_sq_footage.to_f
              footage_val.collateral_id = collateral.id
              footage_val.loan_id = collateral.loan_id
              footage_val.save
              footage_table=1
            else
              old_val = st_footage.value.to_f
              new_val = collateral.structural_sq_footage.to_f
              st_footage.value = old_val + new_val
              st_footage.collateral_id = collateral.id
              st_footage.loan_id = collateral.loan_id
              st_footage.save
              footage_table=1
            end
            collateral_secondarysize += collateral.structural_sq_footage.to_f
            collateral.units=""
            collateral.sf_per_unit=""
            collateral.save
        end
      end
     
        

      if collateral.size=="Sq Footage"
        sq_footage << collateral.sq_footage
        footage_num = CollateralSqfootage.find_by_collateral_id(collateral.id.to_s)
        
        if footage_num.blank?
          footage_val = CollateralSqfootage.new 
          footage_val.value = collateral.sq_footage.to_f
          footage_val.collateral_id = collateral.id
          footage_val.loan_id = collateral.loan_id
          footage_val.save
          footage_table=1
        else
          old_val = footage_num.value.to_f
          new_val = collateral.sq_footage.to_f
          footage_num.value = old_val + new_val
          footage_num.collateral_id = collateral.id
          footage_num.loan_id = collateral.loan_id
          footage_num.save
          footage_table=1
        end

        collateral_secondarysize += collateral.sq_footage.to_f
        collateral.acres=""
        collateral.save
      end
    

    end
  end
   #  @loan.total_primary_sf = ""
   # @loan.total_secondary_size  = ""
   # @loan.save
  # abort("NOI #{@loan.total_noi_ytd} Total Gross #{@loan.total_gross} Acres  #{@loan.total_primary_sf} #{acres.inspect} Secondry #{@loan.total_secondary_size} #{sq_footage.inspect}")
   
  

  if acre_table == 1
    @loan.total_primary_sf = collateral_acres
    @loan.save
  end

   if footage_table == 1
      @loan.total_secondary_size = collateral_secondarysize
      @loan.save
   end
  
  if gross_table == 1
    @loan.total_gross = collateral_total_gross
    @loan.save
  end

  if noi_table == 1
    @loan.total_noi_ytd = noi_ytd
    @loan.save
  end

 # abort("#{noi_ytd} #{noi_ytd_arr.inspect}")

  year = Time.now.year

  start_date = Date.parse "#{year}-01-01 14:46:21 +0100"
  end_date =  Date.parse "#{year}-12-31 14:46:21 +0200"
  @days = (end_date - start_date).to_i + 1

  today_date=Time.now
  # abort("#{today_date}")
  


  ###################### Analysis New ################################
  
  if gross_table == 1
  # if @loan.info['annual_as_is_gross_income'].blank?
    check_start_date = Date.parse "#{@loan.info['created_date_gross']}"
    check_end_date = Date.parse "#{today_date}"
    @check_days = (check_end_date - check_start_date).to_i + 1

     grossincome = (@loan.total_gross.to_f/@check_days)*@days
     @loan.info['annual_as_is_gross_income'] =  number_to_currency(grossincome.round(2))
     @loan.save
  end

  if noi_table == 1
  # if @loan.info['annual_as_is_noi'].blank?
     check_start_date = Date.parse "#{@loan.info['created_date_noi']}"
     check_end_date = Date.parse "#{today_date}"
     @check_days = (check_end_date - check_start_date).to_i + 1

     noiytd = (@loan.total_noi_ytd.to_f/@check_days)*@days
     @loan.info['annual_as_is_noi'] =  number_to_currency(noiytd.round(2))
     @loan.save
  end
  
  if acre_table == 1
  # if @loan.info['land_square_footage'].blank?
    @loan.info['land_square_footage'] = @loan.total_primary_sf.to_f*43560
    @loan.save
  end
   
  if gross_table == 1
  # if @loan.info['structural_square_footage'].blank?
    @loan.info['structural_square_footage'] = @loan.total_secondary_size
    @loan.save
  end

  ###################### End New ################################
   @funds = @loan.use_of_fund 

   if @loan.info['gross_loan_amount'].blank?
    unless @loan.info['_NetLoanAmountRequested0'].blank?
      @loan.info['gross_loan_amount'] = @loan.info['_NetLoanAmountRequested0']
      @loan.save
    end
   end
   
   if @loan.info['acash_to_contribute'].blank?
    unless @loan.info['purchase_cash_contribute'].blank?
      @loan.info['acash_to_contribute'] = @loan.info['purchase_cash_contribute']
      @loan.save
    end
   end

   if @loan.info['apurchase_price'].blank?
    unless @loan.info['purchase_price'].blank?
      @loan.info['apurchase_price'] = @loan.info['purchase_price']
      @loan.save
    end
   end
   
   unless @loan.info['_NetLoanAmountRequested0'].blank?
    unless @loan.info['_EstimatedMarketValue'].blank?
      if @loan.info['as_is_ltv'].blank?
        ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
        @ultv = ltv *100
        @loan.info['as_is_ltv'] = @ultv.round(2)
        @loan.save
      end
    end
   end

  unless @loan.info['analysis_units'].blank?
    unless @loan.info['improved_sale_sf'].blank?
      if @loan.info['unimproved_sf'].blank?
        @loan.info['unimproved_sf'] = @loan.info['analysis_units'] - @loan.info['improved_sale_sf']
        @loan.save
      end
    end
  end

  unless @loan.info['analysis_units'].blank?
    unless @loan.info['as_is_value'].blank?
      if @loan.info['begining_unit'].blank?
        new_as_is_val = @loan.info['as_is_value'].gsub(/[^\d]/, '')
        new_as_is_val = new_as_is_val.to_i
        analysis_units = @loan.info['analysis_units'].to_i
        @loan.info['begining_unit'] = (new_as_is_val.to_f/analysis_units).round(2)
        @loan.save
      end
    end
  end

  unless @loan.info['analysis_units'].blank?
    unless @loan.info['as_improved_value'].blank?
      if @loan.info['improved_unit'].blank?
        new_as_improved_value = @loan.info['as_improved_value'].gsub(/[^\d]/, '')
        new_as_improved_value = new_as_improved_value.to_i
        analysis_units = @loan.info['analysis_units'].to_i
        @loan.info['improved_unit'] = (new_as_improved_value.to_f/analysis_units).round(2)
        @loan.save
      end
    end
  end

  unless @loan.info['analysis_units'].blank?
    unless @loan.info['completed_square_footage'].blank?
      if @loan.info['begining_project_completion'].blank?
        completed_square_footage = @loan.info['completed_square_footage'].to_i
        analysis_units = @loan.info['analysis_units'].to_i
        @loan.info['begining_project_completion'] = (completed_square_footage.to_f/analysis_units)*100.round(2)
        @loan.save
      end
    end
  end


  unless @loan.info['analysis_units'].blank?
    unless @loan.info['improved_sale_sf'].blank?
      if @loan.info['ending_project_completion'].blank?
        improved_sale_sf = @loan.info['improved_sale_sf'].to_i
        analysis_units = @loan.info['analysis_units'].to_i
        @loan.info['ending_project_completion'] = (improved_sale_sf.to_f/analysis_units)*100.round(2)
        @loan.save
      end
    end
  end

  unless @loan.info['acash_to_contribute'].blank?
    unless @loan.info['as_is_value'].blank?
      if @loan.info['cash_value_ratio'].blank?
        new_is_val = @loan.info['as_is_value'].gsub(/[^\d]/, '')
        new_cash_contribute = @loan.info['acash_to_contribute'].gsub(/[^\d]/, '')
        new_cash_contribute = new_cash_contribute.to_i
        new_is_val = new_is_val.to_i
        @loan.info['cash_value_ratio'] = (new_cash_contribute.to_f/new_is_val)*100.round(2)
        @loan.save
      end
    end
  end

  unless @loan.info['gross_loan_amount'].blank?
    unless @loan.info['as_is_value'].blank?
      if @loan.info['as_is_ltv'].blank?
        new_is_val = @loan.info['as_is_value'].gsub(/[^\d]/, '')
        new_gross_loan_amount = @loan.info['gross_loan_amount'].gsub(/[^\d]/, '')
        new_is_val = new_is_val.to_i
        new_gross_loan_amount = new_gross_loan_amount.to_i
        @loan.info['as_is_ltv'] = (new_is_val.to_f/new_gross_loan_amount)*100.round(2)
        @loan.save
      end
    end
  end

  unless @loan.info['gross_loan_amount'].blank?
    unless @loan.info['apurchase_price'].blank?
       if @loan.info['as_is_ltv_purchaseprice'].blank?
      # abort("fdsf")
        new_apurchase_price = @loan.info['apurchase_price'].gsub(/[^\d]/, '')
        new_gross_loan_amount = @loan.info['gross_loan_amount'].gsub(/[^\d]/, '')
        new_gross = new_gross_loan_amount.to_i
        new_apurchase = new_apurchase_price.to_i
        @loan.info['as_is_ltv_purchaseprice'] = (new_gross.to_f/new_apurchase)*100.round(2)
        # abort("#{new_gross.to_f}/#{new_apurchase} = #{@loan.info['as_is_ltv_purchaseprice']}")
        @loan.save
       end
    end
  end

  unless @loan.info['gross_loan_amount'].blank?
    unless @loan.info['as_is_value'].blank?
      if @loan.info['as_improved_ltv'].blank?
        new_gross_loan_amount = @loan.info['gross_loan_amount'].gsub(/[^\d]/, '')
        new_as_is_value = @loan.info['as_is_value'].gsub(/[^\d]/, '')
        new_gross_loan_amount = new_gross_loan_amount.to_i
        new_as_is_value = new_as_is_value.to_i
        @loan.info['as_improved_ltv'] = (new_gross_loan_amount.to_f/new_as_is_value)*100.round(2)
        @loan.save
      end
    end
  end

    col_acres = CollateralAcres.all(:loan_id => @loan.id.to_i)
    @colacres = Hash.new
    col_acres.each do |col_acre|
      @colacres[col_acre.collateral_id.to_s] = col_acre.value
    end
    col_sqs = CollateralSqfootage.all(:loan_id => @loan.id.to_i) 
    @colsqs = Hash.new
    col_sqs.each do |col_sq|
      @colsqs[col_sq.collateral_id.to_s] = col_sq.value
    end
    # abort("#{@colsqs.inspect}")
    col_nois = CollateralNoi.all(:loan_id => @loan.id.to_i)
    @colnois = Hash.new
    col_nois.each do |col_noi|
      @colnois[col_noi.collateral_id.to_s] = col_noi.value
    end
    col_gross = CollateralGross.all(:loan_id => @loan.id.to_i)
    @colgross = Hash.new
    col_gross.each do |col_gros|
      @colgross[col_gros.collateral_id.to_s] = col_gros.value
    end
    # abort("#{@loan.inspect}")

  end
  
 
  def edit_field
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = Loan.find_by_id(params[:contact_id].to_i)
            if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end

            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end


            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Loan.find_by_id(params[:contact_id].to_i)
           if params[:field_name] == "_EstimatedMarketValues"
              @field_value = loan_info.info["_EstimatedMarketValue"]
            else
              @field_value = loan_info.info[params[:field_name]]
            end
            
            # abort("#{@field_value}")
            
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
          if params[:field_name] == "FirstName" || params[:field_name] == "Email" || params[:field_name] == "Phone" 
            render partial: 'contact_mini_form', locals:
            {
              edit: false,
              contact_id: params[:contact_id],
              format_type:params[:format_type],
              field_type: params[:field_type], 
              field_label: params[:field_label], 
              field_name:params[:field_name],
              field_value:@field_value, 
              field_options:params[:field_options]
            }
          else
            render partial: 'mini_form', locals:
            {
              edit: false,
              contact_id: params[:contact_id],
              format_type:params[:format_type],
              field_type: params[:field_type], 
              field_label: params[:field_label], 
              field_name:params[:field_name],
              field_value:@field_value, 
              field_options:params[:field_options]
            } 
          end
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = Loan.find_by_id(params[:contact_id].to_i)
             if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end
                    
            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Loan.find_by_id(params[:contact_id].to_i)
           @field_value = loan_info.info[params[:field_name]]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end

  def borrower_edit_field
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'borrower_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = Borrower.find_by_id(params[:contact_id])
            
            lId=loan_info.loan_id.to_i
            loanInfo = Loan.find_by_id(lId)
            
            if loanInfo.email.blank?
              if params[:field_name].include? "borrower_guarantor" 
                if @field_value=="Yes"
                  unless loan_info.personal_email.blank?
                    loanInfo.email = loan_info.personal_email
                    loanInfo.info['Email'] = loan_info.personal_email
                    loanInfo.info['FirstName'] = loan_info.personal_name
                    loanInfo.info['Phone'] = loan_info.personal_phone
                    loanInfo.save
                  end
                end
              end
            end
            
            # if params[:field_name].include? "email"
            #   if !params[:field_name].include? "personal_email"
            #     loan_info.personal_email = @field_value
            #   end
            # end
             if params[:field_name].include? "borrower_type" 
              loan_info.borrower_type = @field_value
            end
            if params[:field_name].include? "personal_phone" 
              loan_info.personal_phone = @field_value
            end
            if params[:field_name].include? "personal_email"
              loan_info.personal_email = @field_value
            end
            if params[:field_name].include? "personal_name"
              loan_info.personal_name = @field_value
            end
            if params[:field_name].include? "personal_address"
              loan_info.personal_address = @field_value
            end
            if params[:field_name].include? "personal_city"
              loan_info.personal_city = @field_value
            end
            if params[:field_name].include? "personal_state"
              loan_info.personal_state = @field_value
            end
            if params[:field_name].include? "personal_postalcode"
              loan_info.personal_postalcode = @field_value
            end
            if params[:field_name].include? "personal_ein"
              loan_info.personal_ein = @field_value
            end
            
            if params[:field_name].include? "personal_ssn"
              loan_info.personal_ssn = @field_value
            end
            if params[:field_name].include? "personal_gross"
              loan_info.personal_gross = @field_value
            end
            if params[:field_name].include? "personal_cashContribution"
              loan_info.personal_cashContribution = @field_value
            end

          if params[:field_name].include? "estimated_fico"
            loan_info.estimated_fico = @field_value
          end

          if params[:field_name].include? "net_worth"
            loan_info.net_worth = @field_value
          end
          

          if params[:field_name].include? "personal_monthly_income"
            loan_info.personal_monthly_income = @field_value
          end

          if params[:field_name].include? "personal_income_source"
            loan_info.personal_income_source = @field_value
          end

          if params[:field_name].include? "bio"
              loan_info.bio = @field_value
          end
          if params[:field_name].include? "business_name"
            loan_info.business_name = @field_value
          end
           if params[:field_name].include? "business_phone"
            loan_info.business_phone = @field_value
          end
          if params[:field_name].include? "business_address"
            loan_info.business_address = @field_value
          end
          if params[:field_name].include? "business_city"
            loan_info.business_city = @field_value
          end
          if params[:field_name].include? "business_state"
            loan_info.business_state = @field_value
          end
          if params[:field_name].include? "business_postalcode"
            loan_info.business_postalcode = @field_value
          end
          if params[:field_name].include? "time_in_business"
            loan_info.time_in_business = @field_value
          end
          if params[:field_name].include? "revenue_time_period"
            loan_info.revenue_time_period = @field_value
          end
          if params[:field_name].include? "business_ein"
            loan_info.business_ein = @field_value
          end
          if params[:field_name].include? "cash_on_hand"
            loan_info.cash_on_hand = @field_value
          end
          if params[:field_name].include? "est_fico"
            loan_info.est_fico = @field_value
          end
          if params[:field_name].include? "available_credit"
            loan_info.available_credit = @field_value
          end
          if params[:field_name].include? "monthly_noi"
            loan_info.monthly_noi = @field_value
          end
          if params[:field_name].include? "annual_noi"
            loan_info.annual_noi = @field_value
          end
          if params[:field_name].include? "account_recievable"
            loan_info.account_recievable = @field_value
          end
          if params[:field_name].include? "account_payable"
            loan_info.account_payable = @field_value
          end
          if params[:field_name].include? "borrower_guarantor" 
             loan_info.borrower_guarantor = @field_value
          end
          if params[:field_name].include? "guarantor_borrow_money" 
             loan_info.guarantor_borrow_money = @field_value
          end
          if params[:field_name].include? "ever_borrow_money" 
             loan_info.ever_borrow_money = @field_value
          end

          if params[:field_name].include? "personal_dob" 
             loan_info.personal_dob = @field_value
          end

           if params[:field_name].include? "business_type" 
             loan_info.business_type = @field_value
          end

          if params[:field_name].include? "state_of_incorporation" 
             loan_info.state_of_incorporation = @field_value
          end

          if params[:field_name].include? "business_balance_sheet" 
             loan_info.business_balance_sheet = @field_value
          end 

          if params[:field_name].include? "income_how_long" 
             loan_info.income_how_long = @field_value
          end

          if params[:field_name].include? "guarantor_name" 
             loan_info.guarantor_name = @field_value
          end

          if params[:field_name].include? "guarantor_phone" 
             loan_info.guarantor_phone = @field_value
          end

          if params[:field_name].include? "guarantor_email" 
             loan_info.guarantor_email = @field_value
          end

          if params[:field_name].include? "guarantor_address" 
             loan_info.guarantor_address = @field_value
          end

          if params[:field_name].include? "guarantor_state" 
             loan_info.guarantor_state = @field_value
          end

          if params[:field_name].include? "guarantor_city" 
             loan_info.guarantor_city = @field_value
          end

          if params[:field_name].include? "guarantor_postalcode" 
             loan_info.guarantor_postalcode = @field_value
          end

          if params[:field_name].include? "guarantor_monthly_income" 
             loan_info.guarantor_monthly_income = @field_value
          end

          if params[:field_name].include? "guarantor_income_source" 
             loan_info.guarantor_income_source = @field_value
          end

          if params[:field_name].include? "guarantor_income_how_long" 
             loan_info.guarantor_income_how_long = @field_value
          end

          if params[:field_name].include? "guarantor_birthday" 
             loan_info.guarantor_birthday = @field_value
          end

          if params[:field_name].include? "guarantor_ssn" 
             loan_info.guarantor_ssn = @field_value
          end

          if params[:field_name].include? "guarantor_estimated_ficco" 
             loan_info.guarantor_estimated_ficco = @field_value
          end

          if params[:field_name].include? "guarantor_net_worth" 
             loan_info.guarantor_net_worth = @field_value
          end





            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Borrower.find_by_id(params[:contact_id])
          # abort("#{loan_info.feildName}")
          if params[:field_name].include? "personal_phone"
           @field_value = loan_info.personal_phone
          end

          if params[:field_name].include? "income_how_long"
           @field_value = loan_info.income_how_long
          end


          if params[:field_name].include? "guarantor_borrow_money" 
             @field_value = loan_info.guarantor_borrow_money
          end
          if params[:field_name].include? "ever_borrow_money" 
              @field_value = loan_info.ever_borrow_money
          end
          if params[:field_name].include? "borrower_type" 
              @field_value = loan_info.borrower_type
          end
          if params[:field_name].include? "borrower_guarantor" 
              @field_value = loan_info.borrower_guarantor
          end
          if params[:field_name].include? "personal_email"
            @field_value = loan_info.personal_email 
          end
          if params[:field_name].include? "personal_name"
            @field_value = loan_info.personal_name
          end
          if params[:field_name].include? "personal_address"
             @field_value = loan_info.personal_address
          end
          if params[:field_name].include? "personal_city"
            @field_value =  loan_info.personal_city
          end
          if params[:field_name].include? "personal_state"
              @field_value =  loan_info.personal_state
          end
          if params[:field_name].include? "personal_postalcode"
              @field_value =  loan_info.personal_postalcode
          end
          if params[:field_name].include? "personal_ein"
             @field_value = loan_info.personal_ein
          end
          if params[:field_name].include? "personal_ssn"
            @field_value = loan_info.personal_ssn
          end

          if params[:field_name].include? "personal_monthly_income"
              @field_value = loan_info.personal_monthly_income
          end

          
          if params[:field_name].include? "personal_income_source"
              @field_value = loan_info.personal_income_source
          end

          if params[:field_name].include? "personal_gross"
            @field_value = loan_info.personal_gross
          end
          if params[:field_name].include? "personal_cashContribution"
            @field_value = loan_info.personal_cashContribution
          end

          if params[:field_name].include? "estimated_fico"
            @field_value = loan_info.estimated_fico
          end

          if params[:field_name].include? "income_how_long" 
              @field_value = loan_info.income_how_long
          end

           if params[:field_name].include? "personal_dob" 
              @field_value = loan_info.personal_dob
          end

           if params[:field_name].include? "business_type" 
             @field_value =  loan_info.business_type
          end

          if params[:field_name].include? "state_of_incorporation" 
             @field_value = loan_info.state_of_incorporation
          end

          if params[:field_name].include? "business_balance_sheet" 
             @field_value =  loan_info.business_balance_sheet
          end

          if params[:field_name].include? "net_worth"
            @field_value = loan_info.net_worth 
          end

          if params[:field_name].include? "bio"
            @field_value = loan_info.bio
          end
          if params[:field_name].include? "business_name"
            @field_value = loan_info.business_name
          end
           if params[:field_name].include? "business_phone"
            @field_value = loan_info.business_phone
          end
          if params[:field_name].include? "business_address"
            @field_value = loan_info.business_address
          end
          if params[:field_name].include? "business_city"
            @field_value = loan_info.business_city
          end
          if params[:field_name].include? "business_state"
            @field_value = loan_info.business_state
          end
          if params[:field_name].include? "business_postalcode"
            @field_value = loan_info.business_postalcode
          end
          if  params[:field_name].include? "time_in_business"
            @field_value = loan_info.time_in_business
          end
          if params[:field_name].include? "revenue_time_period"
            @field_value = loan_info.revenue_time_period
          end
          if params[:field_name].include? "business_ein"
            @field_value = loan_info.business_ein
          end
           if params[:field_name].include? "cash_on_hand"
            @field_value = loan_info.cash_on_hand
          end
          if params[:field_name].include? "est_fico"
            @field_value = loan_info.est_fico
          end
          if params[:field_name].include? "available_credit"
            @field_value =  loan_info.available_credit
          end
          if params[:field_name].include? "monthly_noi"
            @field_value = loan_info.monthly_noi
          end
          if params[:field_name].include? "annual_noi"
            @field_value = loan_info.annual_noi
          end
          if params[:field_name].include? "account_recievable"
            @field_value = loan_info.account_recievable
          end
          if  params[:field_name].include? "account_payable"
            @field_value = loan_info.account_payable
          end

          if params[:field_name].include? "guarantor_name" 
             @field_value = loan_info.guarantor_name
          end

          if params[:field_name].include? "guarantor_phone" 
             @field_value = loan_info.guarantor_phone
          end

          if params[:field_name].include? "guarantor_email" 
             @field_value = loan_info.guarantor_email
          end

          if params[:field_name].include? "guarantor_address" 
            @field_value =  loan_info.guarantor_address
          end

          if params[:field_name].include? "guarantor_state" 
             @field_value = loan_info.guarantor_state
          end

          if params[:field_name].include? "guarantor_city" 
             @field_value = loan_info.guarantor_city
          end

          if params[:field_name].include? "guarantor_postalcode" 
             @field_value = loan_info.guarantor_postalcode
          end

          if params[:field_name].include? "guarantor_monthly_income" 
             @field_value = loan_info.guarantor_monthly_income
          end

          if params[:field_name].include? "guarantor_income_source" 
             @field_value = loan_info.guarantor_income_source
          end

          if params[:field_name].include? "guarantor_income_how_long" 
             @field_value = loan_info.guarantor_income_how_long
          end

          if params[:field_name].include? "guarantor_birthday" 
             @field_value = loan_info.guarantor_birthday
          end

          if params[:field_name].include? "guarantor_ssn" 
             @field_value = loan_info.guarantor_ssn
          end

          if params[:field_name].include? "guarantor_estimated_ficco" 
             @field_value = loan_info.guarantor_estimated_ficco
          end

          if params[:field_name].include? "guarantor_net_worth" 
             @field_value = loan_info.guarantor_net_worth
          end



          if @format_type == 'fd_money'
            @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
          end
             
          end
    
          render partial: 'borrower_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'borrower_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = Borrower.find_by_id(params[:contact_id])
            
            if params[:field_name] == "email"
              loan_info.email = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Borrower.find_by_id(params[:contact_id])
           @field_value = loan_info.params[:field_name]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'borrrower_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end

  def collateral_edit_field
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'collateral_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = Collateral.find_by_id(params[:contact_id])
            loan = Loan.find_by_id(loan_info.loan_id)
            @collaterals = Collateral.all(:loan_id => loan.id)
            
            year = Time.now.year

            start_date = Date.parse "#{year}-01-01 14:46:21 +0100"
            end_date =  Date.parse "#{year}-12-31 14:46:21 +0200"
            @days = (end_date - start_date).to_i + 1

            today_date=Time.now
            # abort("#{today_date}")
            
            
                
           

            if params[:field_name].include? "address"
                loan_info.address = @field_value
            end
            if params[:field_name].include? "city" 
              loan_info.city = @field_value
            end
            if params[:field_name].include? "state"
              loan_info.state = @field_value
            end
            if params[:field_name].include? "postalcode"
              loan_info.postalcode = @field_value
            end
            if params[:field_name].include? "estimated_value"
              loan_info.estimated_value = @field_value
            end
            if params[:field_name].include? "amount_owed"
              loan_info.amount_owed = @field_value
            end
            if params[:field_name].include? "mortgage_status"
              loan_info.mortgage_status = @field_value
            end
            if params[:field_name].include? "gross_monthly_income"
               
              gross_num = CollateralGross.find_by_collateral_id(loan_info.id.to_s)
              if gross_num.blank?
                gross_val =CollateralGross.new
                gross_val.loan_id = loan.id
                gross_val.collateral_id = loan_info.id
                gross_val.value =  @field_value
                gross_val.save
              else
                gross_num.value = @field_value
                gross_num.save
              end

              if loan.info['created_date_gross'].blank?
                loan.info['created_date_gross'] = loan.created_date
                loan.save
              end

              @col_gross = CollateralGross.all(:loan_id => loan.id)
              collateral_total_gross = 0
              @col_gross.each do |col_gros|
                  collateral_total_gross += col_gros.value.to_f
              end

                today_date = Time.now
                check_start_date = Date.parse "#{loan.info['created_date_gross']}"
                check_end_date = Date.parse "#{today_date}"
                @check_days = (check_end_date - check_start_date).to_i + 1

               loan.total_gross = collateral_total_gross
               grossincome = (collateral_total_gross.to_f/@check_days)*@days
               loan.info['annual_as_is_gross_income'] =  number_to_currency(grossincome.round(2))
               loan.save
               
               loan_info.gross_monthly_income = @field_value

            end

            if params[:field_name].include? "structural_size"
              # if loan_info.structural_size == "Acres" && @field_value != "Acres"
              #   if @field_value == "Sq Footage"
              #     CollateralAcres.delete_all(:collateral_id => loan_info.id.to_s)
              #     @col_acres = CollateralAcres.all(:loan_id => loan.id)
              #     collateral_acre = 0
              #     @col_acres.each do |acres|
              #         collateral_acre += acres.value.to_f
              #     end

              #     loan.total_primary_sf = collateral_acre
              #     loan.info['land_square_footage'] = collateral_acre.to_f*43560
              #     loan.save
              #   end
              # end

              # if loan_info.size == "Sq Footage" && @field_value != "Sq Footage"
              #   if @field_value == "Acres"
              #     CollateralSqfootage.delete_all(:collateral_id => loan_info.id.to_s)
              #     @col_footage = CollateralSqfootage.all(:loan_id => loan.id)
              #     collateral_sqfootage = 0
              #     @col_footage.each do |footage|
              #         collateral_sqfootage += footage.value.to_f
              #     end
              #     loan.total_secondary_size = collateral_sqfootage
              #     loan.info['structural_square_footage'] = collateral_sqfootage
              #     loan.save
              #   end
              # end
              loan_info.structural_size = @field_value
            end
            if params[:field_name].include? "structural_sq_footage"
              loan_info.structural_sq_footage = @field_value

            end
            if params[:field_name].include? "sf_per_unit"
              loan_info.sf_per_unit = @field_value
            end

            ####

            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end
            if params[:field_name].include? "asset_type"
              loan_info.asset_type = @field_value
            end
            if params[:field_name].include? "source_of_value"
              loan_info.source_of_value = @field_value
            end
            if params[:field_name].include? "date_last_valuation"
              loan_info.date_last_valuation = @field_value
            end
            if params[:field_name].include? "date_last_bpo"
              loan_info.date_last_bpo = @field_value
            end
            if params[:field_name].include? "size"
              
              if loan_info.size == "Acres" && @field_value != "Acres"
                if @field_value == "Sq Footage"
                  CollateralAcres.delete_all(:collateral_id => loan_info.id.to_s)
                  @col_acres = CollateralAcres.all(:loan_id => loan.id)
                  collateral_acre = 0
                  @col_acres.each do |acres|
                      collateral_acre += acres.value.to_f
                  end

                  loan.total_primary_sf = collateral_acre
                  loan.info['land_square_footage'] = collateral_acre.to_f*43560
                  loan.save


                end
              end

              if loan_info.size == "Sq Footage" && @field_value != "Sq Footage"
                if @field_value == "Acres"
                  CollateralSqfootage.delete_all(:collateral_id => loan_info.id.to_s)
                  @col_footage = CollateralSqfootage.all(:loan_id => loan.id)
                  collateral_sqfootage = 0
                  @col_footage.each do |footage|
                      collateral_sqfootage += footage.value.to_f
                  end
                  loan.total_secondary_size = collateral_sqfootage
                  loan.info['structural_square_footage'] = collateral_sqfootage
                  loan.save
                end
              end

              loan_info.size = @field_value
              
            end
            if params[:field_name].include? "sq_footage"
              
              footage_num = CollateralSqfootage.find_by_collateral_id(loan_info.id.to_s)
              if footage_num.blank?
                footage_val =CollateralSqfootage.new
                footage_val.loan_id = loan.id
                footage_val.collateral_id = loan_info.id
                footage_val.value =  @field_value
                footage_val.save
              else
                footage_num.value = @field_value
                footage_num.save
              end

              @col_footage = CollateralSqfootage.all(:loan_id => loan.id)
              collateral_sqfootage = 0
              @col_footage.each do |footage|
                  collateral_sqfootage += footage.value.to_f
              end
              loan.total_secondary_size = collateral_sqfootage 
              loan.info['structural_square_footage'] = collateral_sqfootage
              loan.save

              loan_info.sq_footage = @field_value
              loan_info.acres = ""
            
            end
            
            if params[:field_name].include? "acres"
              
              acre_num = CollateralAcres.find_by_collateral_id(loan_info.id.to_s)
              if acre_num.blank?
                acre_val =CollateralAcres.new
                acre_val.loan_id = loan.id
                acre_val.collateral_id = loan_info.id
                acre_val.value =  @field_value
                acre_val.save
              else
                acre_num.value = @field_value
                acre_num.save
              end

              @col_acres = CollateralAcres.all(:loan_id => loan.id)
              collateral_acre = 0
              @col_acres.each do |acres|
                  collateral_acre += acres.value.to_f
              end

              loan.total_primary_sf = collateral_acre
              loan.info['land_square_footage'] = collateral_acre.to_f*43560
              loan.save
              # abort("#{loan.insect}")
              loan_info.acres = @field_value
              loan_info.sq_footage = ""
                          
            end
            
            if params[:field_name].include? "noi_ytd"

              total_noi_ytd = loan_info.noi_ytd.to_f
                 noi_num = CollateralNoi.find_by_collateral_id(loan_info.id.to_s)
                if noi_num.blank?
                  noi_val =CollateralNoi.new
                  noi_val.loan_id = loan.id
                  noi_val.collateral_id = loan_info.id
                  noi_val.value =  @field_value
                  noi_val.save
                else
                  noi_num.value = @field_value
                  noi_num.save
                end



                if loan.info['created_date_noi'].blank?
                  loan.info['created_date_noi'] = loan.created_date
                  loan.save
                end

                 today_date = Time.now
                check_start_date = Date.parse "#{loan.info['created_date_noi']}"
                check_end_date = Date.parse "#{today_date}"
                @check_days = (check_end_date - check_start_date).to_i + 1

                @col_noi = CollateralNoi.all(:loan_id => loan.id)
                collateral_noi = 0
                @col_noi.each do |noi|
                    collateral_noi += noi.value.to_f
                end
                loan.total_noi_ytd = collateral_noi
                annual_as_is_noi = (collateral_noi.to_f/@check_days)*@days
                loan.info['annual_as_is_noi'] =  number_to_currency(annual_as_is_noi.round(2))
                loan.save
                
                loan_info.noi_ytd = @field_value
            
            end

            if params[:field_name].include? "noi_two_years_ago"
              loan_info.noi_two_years_ago = @field_value
            end
            if params[:field_name].include? "noi_last_year"
              loan_info.noi_last_year = @field_value
            end
             if params[:field_name].include? "transaction_type"
              loan_info.transaction_type = @field_value
            end
             if params[:field_name].include? "contract_closing_date"
              loan_info.contract_closing_date = @field_value
            end
            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            if params[:field_name].include? "rehab_amount"
              loan_info.rehab_amount = @field_value
            end
            if params[:field_name].include? "purchase_cash_contribute"
              loan_info.purchase_cash_contribute = @field_value
            end
            if params[:field_name].include? "maturity_date"
              loan_info.maturity_date = @field_value
            end
             if params[:field_name].include? "refinance_cash_contribute"
              loan_info.refinance_cash_contribute = @field_value
            end
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end

             if params[:field_name].include? "vested_by"
              loan_info.vested_by = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

            if params[:field_name].include? "collateral_value"
              loan_info.collateral_value = @field_value
            end
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Collateral.find_by_id(params[:contact_id])
          if params[:field_name].include? "address"
             @field_value = loan_info.address
            end
            if params[:field_name].include? "city" 
              @field_value = loan_info.city
            end
            if params[:field_name].include? "state"
              @field_value= loan_info.state
            end
            if params[:field_name].include? "postalcode"
              @field_value = loan_info.postalcode
            end
            if params[:field_name].include? "estimated_value"
              @field_value = loan_info.estimated_value
            end
            if params[:field_name].include? "amount_owed"
              @field_value= loan_info.amount_owed
            end
            if params[:field_name].include? "mortgage_status"
             @field_value = loan_info.mortgage_status
            end
            if params[:field_name].include? "gross_monthly_income"
              @field_value = loan_info.gross_monthly_income
            end

            if params[:field_name].include? "purchase_price"
              @field_value = loan_info.purchase_price
            end
            
            if params[:field_name].include? "original_purchase_price"
              @field_value = loan_info.original_purchase_price
            end

             if params[:field_name].include? "asset_type"
              @field_value = loan_info.asset_type
            end
            if params[:field_name].include? "source_of_value"
              @field_value = loan_info.source_of_value
            end
            if params[:field_name].include? "date_last_valuation"
              @field_value = loan_info.date_last_valuation
            end
            if params[:field_name].include? "date_last_bpo"
              @field_value = loan_info.date_last_bpo
            end
            
            if params[:field_name].include? "size"
             @field_value = loan_info.size
            end

            if params[:field_name].include? "sq_footage"
              @field_value = loan_info.sq_footage
            end
            if params[:field_name].include? "units"
              @field_value = loan_info.units
            end
            
            if params[:field_name].include? "acres"
              @field_value = loan_info.acres
            end
            if params[:field_name].include? "noi_ytd"
              @field_value = loan_info.noi_ytd
            end
            if params[:field_name].include? "noi_two_years_ago"
              @field_value = loan_info.noi_two_years_ago
            end
            if params[:field_name].include? "noi_last_year"
              @field_value = loan_info.noi_last_year
            end
             if params[:field_name].include? "transaction_type"
              @field_value = loan_info.transaction_type
            end
             if params[:field_name].include? "contract_closing_date"
              @field_value = loan_info.contract_closing_date
            end
            if params[:field_name].include? "purchase_price"
              @field_value = loan_info.purchase_price
            end
            if params[:field_name].include? "rehab_amount"
              @field_value = loan_info.rehab_amount
            end
            if params[:field_name].include? "purchase_cash_contribute"
              @field_value = loan_info.purchase_cash_contribute
            end
            if params[:field_name].include? "maturity_date"
              @field_value = loan_info.maturity_date
            end
             if params[:field_name].include? "refinance_cash_contribute"
              @field_value= loan_info.refinance_cash_contribute
            end
            if params[:field_name].include? "original_purchase_price"
              @field_value = loan_info.original_purchase_price
            end

             if params[:field_name].include? "vested_by"
              @field_value = loan_info.vested_by
            end

             if params[:field_name].include? "cash_contributed"
              @field_value = loan_info.gross_monthly_income
            end

             

          if @format_type == 'fd_money'
            @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
          end
             
          end
    
          render partial: 'collateral_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'collateral_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = Collateral.find_by_id(params[:contact_id])
            
            if params[:field_name] == "email"
              loan_info.email = @field_value
            end
            
            if params[:field_name].include? "address"
                loan_info.address = @field_value
            end
            if params[:field_name].include? "city" 
              loan_info.city = @field_value
            end
            if params[:field_name].include? "state"
              loan_info.state = @field_value
            end
            if params[:field_name].include? "postalcode"
              loan_info.postalcode = @field_value
            end
            if params[:field_name].include? "estimated_value"
              loan_info.estimated_value = @field_value
            end
            if params[:field_name].include? "amount_owed"
              loan_info.amount_owed = @field_value
            end
            if params[:field_name].include? "mortgage_status"
              loan_info.mortgage_status = @field_value
            end
            if params[:field_name].include? "gross_monthly_income"
              loan_info.gross_monthly_income = @field_value
            end

            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end

             if params[:field_name].include? "asset_type"
              loan_info.asset_type = @field_value
            end
            if params[:field_name].include? "source_of_value"
              loan_info.source_of_value = @field_value
            end
            if params[:field_name].include? "date_last_valuation"
              loan_info.date_last_valuation = @field_value
            end
            if params[:field_name].include? "date_last_bpo"
              loan_info.date_last_bpo = @field_value
            end
            if params[:field_name].include? "size"
              loan_info.size = @field_value
            end
            if params[:field_name].include? "sq_footage"
              loan_info.sq_footage = @field_value
            end
            if params[:field_name].include? "units"
              loan_info.units = @field_value
            end
            if params[:field_name].include? "acres"
              loan_info.acres = @field_value
            end
            if params[:field_name].include? "acres"
              loan_info.acres = @field_value
            end
            if params[:field_name].include? "noi_ytd"
              loan_info.noi_ytd = @field_value
            end
            if params[:field_name].include? "noi_two_years_ago"
              loan_info.noi_two_years_ago = @field_value
            end
            if params[:field_name].include? "noi_last_year"
              loan_info.noi_last_year = @field_value
            end
             if params[:field_name].include? "transaction_type"
              loan_info.transaction_type = @field_value
            end
             if params[:field_name].include? "contract_closing_date"
              loan_info.contract_closing_date = @field_value
            end
            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            if params[:field_name].include? "rehab_amount"
              loan_info.rehab_amount = @field_value
            end
            if params[:field_name].include? "purchase_cash_contribute"
              loan_info.purchase_cash_contribute = @field_value
            end
            if params[:field_name].include? "maturity_date"
              loan_info.maturity_date = @field_value
            end
             if params[:field_name].include? "refinance_cash_contribute"
              loan_info.refinance_cash_contribute = @field_value
            end
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end

             if params[:field_name].include? "vested_by"
              loan_info.vested_by = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Collateral.find_by_id(params[:contact_id])
           @field_value = loan_info.params[:field_name]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'collateral_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end

  def collaterals_edit_field
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'collaterals_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = CopyCollateral.find_by_id(params[:contact_id])
            

            if params[:field_name].include? "address"
                loan_info.address = @field_value
            end
            if params[:field_name].include? "city" 
              loan_info.city = @field_value
            end
            if params[:field_name].include? "state"
              loan_info.state = @field_value
            end
            if params[:field_name].include? "postalcode"
              loan_info.postalcode = @field_value
            end
            if params[:field_name].include? "estimated_value"
              loan_info.estimated_value = @field_value
            end
            if params[:field_name].include? "amount_owed"
              loan_info.amount_owed = @field_value
            end
            if params[:field_name].include? "mortgage_status"
              loan_info.mortgage_status = @field_value
            end
            if params[:field_name].include? "gross_monthly_income"
              loan_info.gross_monthly_income = @field_value
            end

            ####

            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end
            if params[:field_name].include? "asset_type"
              loan_info.asset_type = @field_value
            end
            if params[:field_name].include? "source_of_value"
              loan_info.source_of_value = @field_value
            end
            if params[:field_name].include? "date_last_valuation"
              loan_info.date_last_valuation = @field_value
            end
            if params[:field_name].include? "date_last_bpo"
              loan_info.date_last_bpo = @field_value
            end
            if params[:field_name].include? "size"
              loan_info.size = @field_value
            end
            if params[:field_name].include? "sq_footage"
              loan_info.sq_footage = @field_value
            end
            if params[:field_name].include? "units"
              loan_info.units = @field_value
            end
            if params[:field_name].include? "acres"
              loan_info.acres = @field_value
            end
            if params[:field_name].include? "acres"
              loan_info.acres = @field_value
            end
            if params[:field_name].include? "noi_ytd"
              loan_info.noi_ytd = @field_value
            end
            if params[:field_name].include? "noi_two_years_ago"
              loan_info.noi_two_years_ago = @field_value
            end
            if params[:field_name].include? "noi_last_year"
              loan_info.noi_last_year = @field_value
            end
             if params[:field_name].include? "transaction_type"
              loan_info.transaction_type = @field_value
            end
             if params[:field_name].include? "contract_closing_date"
              loan_info.contract_closing_date = @field_value
            end
            if params[:field_name].include? "purchase_price"
              loan_info.purchase_price = @field_value
            end
            if params[:field_name].include? "rehab_amount"
              loan_info.rehab_amount = @field_value
            end
            if params[:field_name].include? "purchase_cash_contribute"
              loan_info.purchase_cash_contribute = @field_value
            end
            if params[:field_name].include? "maturity_date"
              loan_info.maturity_date = @field_value
            end
             if params[:field_name].include? "refinance_cash_contribute"
              loan_info.refinance_cash_contribute = @field_value
            end
            if params[:field_name].include? "original_purchase_price"
              loan_info.original_purchase_price = @field_value
            end

             if params[:field_name].include? "vested_by"
              loan_info.vested_by = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

             if params[:field_name].include? "cash_contributed"
              loan_info.cash_contributed = @field_value
            end

            if params[:field_name].include? "collateral_value"
              loan_info.collateral_value = @field_value
            end
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyCollateral.find_by_id(params[:contact_id])
          # abort("#{loan_info.feildName}")
           if params[:field_name].include? "address"
             @field_value = loan_info.address
            end

            if params[:field_name].include? "collateral_value"
             @field_value = loan_info.collateral_value
            end

            if params[:field_name].include? "city" 
              @field_value = loan_info.city
            end
            if params[:field_name].include? "state"
              @field_value= loan_info.state
            end
            if params[:field_name].include? "postalcode"
              @field_value = loan_info.postalcode
            end
            if params[:field_name].include? "estimated_value"
              @field_value = loan_info.estimated_value
            end
            if params[:field_name].include? "amount_owed"
              @field_value= loan_info.amount_owed
            end
            if params[:field_name].include? "mortgage_status"
             @field_value = loan_info.mortgage_status
            end
            if params[:field_name].include? "gross_monthly_income"
              @field_value = loan_info.gross_monthly_income
            end

            if params[:field_name].include? "purchase_price"
              @field_value = loan_info.purchase_price
            end
            
            if params[:field_name].include? "original_purchase_price"
              @field_value = loan_info.original_purchase_price
            end

             if params[:field_name].include? "asset_type"
              @field_value = loan_info.asset_type
            end
            if params[:field_name].include? "source_of_value"
              @field_value = loan_info.source_of_value
            end
            if params[:field_name].include? "date_last_valuation"
              @field_value = loan_info.date_last_valuation
            end
            if params[:field_name].include? "date_last_bpo"
              @field_value = loan_info.date_last_bpo
            end
            if params[:field_name].include? "size"
             @field_value = loan_info.size
            end
            if params[:field_name].include? "sq_footage"
              @field_value = loan_info.sq_footage
            end
            if params[:field_name].include? "units"
              @field_value = loan_info.units
            end
            
            if params[:field_name].include? "acres"
              @field_value = loan_info.acres
            end
            if params[:field_name].include? "noi_ytd"
              @field_value = loan_info.noi_ytd
            end
            if params[:field_name].include? "noi_two_years_ago"
              @field_value = loan_info.noi_two_years_ago
            end
            if params[:field_name].include? "noi_last_year"
              @field_value = loan_info.noi_last_year
            end
             if params[:field_name].include? "transaction_type"
              @field_value = loan_info.transaction_type
            end
             if params[:field_name].include? "contract_closing_date"
              @field_value = loan_info.contract_closing_date
            end
            if params[:field_name].include? "purchase_price"
              @field_value = loan_info.purchase_price
            end
            if params[:field_name].include? "rehab_amount"
              @field_value = loan_info.rehab_amount
            end
            if params[:field_name].include? "purchase_cash_contribute"
              @field_value = loan_info.purchase_cash_contribute
            end
            if params[:field_name].include? "maturity_date"
              @field_value = loan_info.maturity_date
            end
             if params[:field_name].include? "refinance_cash_contribute"
              @field_value= loan_info.refinance_cash_contribute
            end
            if params[:field_name].include? "original_purchase_price"
              @field_value = loan_info.original_purchase_price
            end

             if params[:field_name].include? "vested_by"
              @field_value = loan_info.vested_by
            end

             if params[:field_name].include? "cash_contributed"
              @field_value = loan_info.gross_monthly_income
            end


          if @format_type == 'fd_money'
            @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
          end
             
          end
    
          render partial: 'collaterals_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'collaterals_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = CopyCollateral.find_by_id(params[:contact_id])
            
            if params[:field_name] == "email"
              loan_info.email = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyCollateral.find_by_id(params[:contact_id])
           @field_value = loan_info.params[:field_name]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'collaterals_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end


  def borrowers_edit_field
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'borrowers_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = CopyBorrower.find_by_id(params[:contact_id])
            

             if params[:field_name].include? "email"
              if !params[:field_name].include? "personal_email"
                loan_info.email = @field_value
              end
            end
             if params[:field_name].include? "borrower_type" 
              loan_info.borrower_type = @field_value
            end
            if params[:field_name].include? "personal_phone" 
              loan_info.personal_phone = @field_value
            end
            if params[:field_name].include? "personal_email"
              loan_info.personal_email = @field_value
            end
            if params[:field_name].include? "personal_name"
              loan_info.personal_name = @field_value
            end
            if params[:field_name].include? "personal_address"
              loan_info.personal_address = @field_value
            end
            if params[:field_name].include? "personal_city"
              loan_info.personal_city = @field_value
            end
            if params[:field_name].include? "personal_state"
              loan_info.personal_state = @field_value
            end
            if params[:field_name].include? "personal_postalcode"
              loan_info.personal_postalcode = @field_value
            end
            if params[:field_name].include? "personal_ein"
              loan_info.personal_ein = @field_value
            end
            if params[:field_name].include? "personal_ein"
              loan_info.personal_ein = @field_value
            end
            if params[:field_name].include? "personal_ssn"
              loan_info.personal_ssn = @field_value
            end
            if params[:field_name].include? "personal_gross"
              loan_info.personal_gross = @field_value
            end
            if params[:field_name].include? "personal_cashContribution"
              loan_info.personal_cashContribution = @field_value
            end
            if params[:field_name].include? "bio"
            loan_info.bio = @field_value
          end
          if params[:field_name].include? "business_name"
            loan_info.business_name = @field_value
          end
           if params[:field_name].include? "business_phone"
            loan_info.business_phone = @field_value
          end
          if params[:field_name].include? "business_address"
            loan_info.business_address = @field_value
          end
          if params[:field_name].include? "business_city"
            loan_info.business_city = @field_value
          end
          if params[:field_name].include? "business_state"
            loan_info.business_state = @field_value
          end
          if params[:field_name].include? "business_postalcode"
            loan_info.business_postalcode = @field_value
          end
          if params[:field_name].include? "time_in_business"
            loan_info.time_in_business = @field_value
          end
          if params[:field_name].include? "revenue_time_period"
            loan_info.revenue_time_period = @field_value
          end
          if params[:field_name].include? "business_ein"
            loan_info.business_ein = @field_value
          end
          if params[:field_name].include? "cash_on_hand"
            loan_info.cash_on_hand = @field_value
          end
          if params[:field_name].include? "est_fico"
            loan_info.est_fico = @field_value
          end
          if params[:field_name].include? "available_credit"
            loan_info.available_credit = @field_value
          end
          if params[:field_name].include? "monthly_noi"
            loan_info.monthly_noi = @field_value
          end
          if params[:field_name].include? "annual_noi"
            loan_info.annual_noi = @field_value
          end
          if params[:field_name].include? "account_recievable"
            loan_info.account_recievable = @field_value
          end
          if params[:field_name].include? "account_payable"
            loan_info.account_payable = @field_value
          end
          if params[:field_name].include? "borrower_guarantor" 
             loan_info.borrower_guarantor = @field_value
          end

            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyBorrower.find_by_id(params[:contact_id])
          # abort("#{loan_info.feildName}")
           if params[:field_name].include? "personal_phone"
           @field_value = loan_info.personal_phone
          end
          if params[:field_name].include? "borrower_type" 
              @field_value = loan_info.borrower_type
          end
          if params[:field_name].include? "borrower_guarantor" 
              @field_value = loan_info.borrower_guarantor
          end
          if params[:field_name].include? "personal_email"
            loan_info.personal_email = @field_value
          end
          if params[:field_name].include? "personal_name"
              loan_info.personal_name = @field_value
          end
          if params[:field_name].include? "personal_address"
            loan_info.personal_address = @field_value
          end
          if params[:field_name].include? "personal_city"
            loan_info.personal_city = @field_value
          end
          if params[:field_name].include? "personal_state"
              loan_info.personal_state = @field_value
          end
          if params[:field_name].include? "personal_postalcode"
              loan_info.personal_postalcode = @field_value
          end
          if params[:field_name].include? "personal_ein"
            loan_info.personal_ein = @field_value
          end
          if params[:field_name].include? "personal_ssn"
            loan_info.personal_ssn = @field_value
          end
          if params[:field_name].include? "personal_gross"
            loan_info.personal_gross = @field_value
          end
          if params[:field_name].include? "personal_cashContribution"
            loan_info.personal_cashContribution = @field_value
          end
          if params[:field_name].include? "bio"
            loan_info.bio = @field_value
          end
          if params[:field_name].include? "business_name"
            loan_info.business_name = @field_value
          end
           if params[:field_name].include? "business_phone"
            loan_info.business_phone = @field_value
          end
          if params[:field_name].include? "business_address"
            loan_info.business_address = @field_value
          end
          if params[:field_name].include? "business_city"
            loan_info.business_city = @field_value
          end
          if params[:field_name].include? "business_state"
            loan_info.business_state = @field_value
          end
          if params[:field_name].include? "business_postalcode"
            loan_info.business_postalcode = @field_value
          end
          if  params[:field_name].include? "time_in_business"
            loan_info.time_in_business = @field_value
          end
          if params[:field_name].include? "revenue_time_period"
            loan_info.revenue_time_period = @field_value
          end
          if params[:field_name].include? "business_ein"
            loan_info.business_ein = @field_value
          end
           if params[:field_name].include? "cash_on_hand"
            loan_info.cash_on_hand = @field_value
          end
          if params[:field_name].include? "est_fico"
            loan_info.est_fico = @field_value
          end
          if params[:field_name].include? "available_credit"
            loan_info.available_credit = @field_value
          end
          if params[:field_name].include? "monthly_noi"
            loan_info.monthly_noi = @field_value
          end
          if params[:field_name].include? "annual_noi"
            loan_info.annual_noi = @field_value
          end
          if params[:field_name].include? "account_recievable"
            loan_info.account_recievable = @field_value
          end
          if  params[:field_name].include? "account_payable"
            loan_info.account_payable = @field_value
          end


          if @format_type == 'fd_money'
            @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
          end
             
          end
    
          render partial: 'borrowers_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'borrowers_mini_form', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = CopyBorrower.find_by_id(params[:contact_id])
            
            if params[:field_name] == "email"
              loan_info.email = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyBorrower.find_by_id(params[:contact_id])
           @field_value = loan_info.params[:field_name]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'borrrowers_mini_form', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end




  
  def update_amount_owed
    @loan = Loan.find_by_id(params[:id].to_i)
     # render plain: @loan.info
     # return
    if params[:_FreeandClear0] == '0'
      render partial: 'mini_form', locals:
          {
            edit: false,
            contact_id:params[:id],
            format_type: 'fd_money',
            field_type: 'text_field_tag', 
            field_label: 'Amount Owed', 
            field_name: '_AmountOwed',
            field_value: @loan.info['_AmountOwed'],
            field_options: ''
          }
    else
      render partial: 'mini_form', locals:
          {
            edit: false,
            contact_id:params[:id],
            format_type: 'fd_money',
            field_type: 'text_field_tag', 
            field_label: 'Amount Owed', 
            field_name: '_AmountOwed',
            field_value: 0,
            field_options: ''
          }
    end
  end
   
  
  def edit_category
    lx = Loan.find_by_id(params[:id].to_i)
    loan = Loan.find_by_id(params[:id].to_i)
    if loan.blank?
      lx = CopyLoan.find_by_id(params[:id])
      loan = CopyLoan.find_by_id(params[:id])
      loan.info["_LendingCategory"] = params[:_LendingCategory] 
      loanCat = CopyLoan.category_type_fields[loan.info["_LendingCategory"]]
      loan.info[loanCat] = params[loanCat]
    else
      loan.info["_LendingCategory"] = params[:_LendingCategory] 
      loanCat = Loan.category_type_fields[loan.info["_LendingCategory"]]
      loan.info[loanCat] = params[loanCat]
    end
   if params[:edit]=='true' 

      render partial: 'loan_category', locals:{contact: loan, edit: true}
      
   else
       if !params.has_key?('cancel')
        #Infusionsoft.contact_update(params[:id], { '_LendingCategory' => params[:_LendingCategory], loanCat=>params[loanCat]})
        loan.info['_LendingCategory']=params[:_LendingCategory]
        loan.info['loanCat']=params[loanCat]
        loan.save()
      else
        #temp = Infusionsoft.data_load('Contact', params[:contact_id], ['_LendingCategory', loanCat])
        loan.info["_LendingCategory"] = lx.info["_LendingCategory"]
        loan[loanCat] =  lx.info['loanCat']
      end
 
      
      render partial: 'loan_category', locals:{contact: loan, edit: false}
   end
    
  end
 
 
 
  def edit_loan_type
    types = Loan.category_type_fields
    loanCat = params[:_LendingCategory]
    loan_type_options = Loan.loan_type_options
    # render text: loan_type_options[loanCat]
    # return
    render partial: 'loan_type_form', locals:{category: types[loanCat], options: loan_type_options[loanCat], field_value: ''}
  end
  
  
  def images
    loan = Loan.find_by_id(params[:id].to_i)
    if !loan.blank?
      loan.get_images
      temp = loan.images
    render partial: 'thumbnails', locals:{images: temp, loan_id:loan._id}
    end

  end
  
  def image
    loan = Loan.find_by_id(params[:id].to_i)
    if !loan.blank?
      loan.images.each do |item|
        if item[:file_id].to_s==params[:image_id].to_s
           send_data Base64.decode64(item[:data]),
            :type => item[:src], :disposition => 'inline'
          return;
        end
      end
    end
  end


  #upload the main image for the loan
  def upload_main_image
   loan=Loan.find_by_id(params[:id].to_i)

   if (loan.info['added_by'].blank?)
      Rails.logger.info "User added by is blank, finding user by email"
      if(loan.email.blank?)
        Rails.logger.info "Loan.email does not exists, means it came from some other source, adding documents to Admin's S3 Bucket"
        uInfo = nil;
      else
        uInfo = User.find_by_email(loan.email)
      end

   else
      Rails.logger.info "User added by exists, so getting userinfo from that"
      uInfo = User.find_by_id(loan.info['added_by'])

   end

   Rails.logger.info "User information #{uInfo.inspect}"
   if(uInfo.nil?)
  
    @bucketName = S3_BUCKET_NAME
  
  else
    # || uInfo.bucket_name.nil?
    @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

  end

   
   up_size = number_to_human_size(params[:upload].size)
   uploaded_io = params[:upload]
   file_name = uploaded_io.original_filename
   File.open(Rails.root.join('public', 'temp', file_name), 'wb') do |file|
   contents = uploaded_io.read
   file.write(contents)
      
      
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_name
      
     # if defined? my_bucket
      #  obj = S3.put_object(
       #        acl: "public-read",
        #       bucket: my_bucket,
         #      key: key_name,
          #     body: contents
           #    )
      #else
        obj = S3.put_object(
               acl: "public-read",
               bucket: S3_BUCKET_NAME,
               key: key_name,
               body: contents
               )
      #end

       

       #clear all featured image tags
        @check = false
        loan.images.each do |img|
              if img.featured 
              img.featured = false
              img.save()
             end
        end
        
        # if obj.last_page?
            ext =  file_name.split('.').last.downcase 
            check = Image.find_by_name(file_name)
            if check && check.loan_id == loan.id
              image = check
            else
            
              if defined? my_bucket  
                image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_name, :url=>"https://s3-us-west-2.amazonaws.com/#{my_bucket}/#{loan.id}/#{file_name}");
              else
                image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_name, :url=>"https://s3-us-west-2.amazonaws.com/#{S3_BUCKET_NAME}/#{loan.id}/#{file_name}");
              end

            end
            image.featured = true
            image.save()
         # end   
      
    end


    redirect_to action: 'show', id: params[:id]
  end

  def upload_main_imagex
   loan=Loan.find_by_id(params[:id].to_i)

   if (loan.info['added_by'].blank?)
      Rails.logger.info "User added by is blank, finding user by email"
      if(loan.email.blank?)
        Rails.logger.info "Loan.email does not exists, means it came from some other source, adding documents to Admin's S3 Bucket"
        uInfo = nil;
      else
        uInfo = User.find_by_email(loan.email)
      end

   else
      Rails.logger.info "User added by exists, so getting userinfo from that"
      uInfo = User.find_by_id(loan.info['added_by'])

   end

   Rails.logger.info "User information #{uInfo.inspect}"
   if(uInfo.nil?)
  
    @bucketName = S3_BUCKET_NAME
  
  else
    # || uInfo.bucket_name.nil?
    @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

  end

   
   newtime= Time.now.strftime("%m-%d-%y_%H-%M-%S")
   file_name = "#{newtime}.png"
   urll= params[:feature_fullpath]
   
   imgxPath = urll.gsub("data:image/png;base64,", '')
   img_path =   Base64.decode64("#{imgxPath}")
   File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|

   # contents = uploaded_io.read
   file.write img_path
      
      
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_name
      
     # if defined? my_bucket
      #  obj = S3.put_object(
       #        acl: "public-read",
        #       bucket: my_bucket,
         #      key: key_name,
          #     body: contents
           #    )
      #else
        obj = S3.put_object(
               acl: "public-read",
               bucket: S3_BUCKET_NAME,
               key: key_name,
               body: img_path
               )
      #end

       

       #clear all featured image tags
        @check = false
        loan.images.each do |img|
              if img.featured 
              img.featured = false
              img.save()
             end
        end
        
       # up_size = number_to_human_size(File.size(Rails.root.join('public', 'temp', 'test16.png')))
        # abort("#{up_size}")


        # if obj.last_page?
            ext =  file_name.split('.').last.downcase 
            check = Image.find_by_name(file_name)
            if check && check.loan_id == loan.id
              image = check
            else
            
              if defined? my_bucket  
                image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_name, :url=>"https://s3-us-west-2.amazonaws.com/#{my_bucket}/#{loan.id}/#{file_name}");
              else
                image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_name, :url=>"https://s3-us-west-2.amazonaws.com/#{S3_BUCKET_NAME}/#{loan.id}/#{file_name}");
              end

            end
            image.featured = true
            image.save()
         # end   
      
    end


    redirect_to action: 'show', id: params[:id]
  end




  def upload_image
   loan=Loan.find_by_id(params[:id].to_i)
  if (loan.info['added_by'].blank?)
      Rails.logger.info "User added by is blank, finding user by email"
      if(loan.email.blank?)
        Rails.logger.info "Loan.email does not exists, means it came from some other source, adding documents to Admin's S3 Bucket"
        uInfo = nil;
      else
        uInfo = User.find_by_email(loan.email)
      end

   else
      Rails.logger.info "User added by exists, so getting userinfo from that"
      uInfo = User.find_by_id(loan.info['added_by'])

   end

   Rails.logger.info "User information #{uInfo.inspect}"
   if(uInfo.nil?)
  
    @bucketName = S3_BUCKET_NAME
  
  else
    # || uInfo.bucket_name.nil?
    @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

  end


   files =  params[:files]
   output = Hash.new
   output['files']=Array.new
   
   files.each do |file_io|
     ext = Rack::Mime::MIME_TYPES.invert["#{file_io.content_type}"]
   file_new = "img_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+ext
     # file_name=file_io.original_filename
     
     File.open(Rails.root.join('public', 'temp', file_new), 'wb') do |file|
        
      contents = file_io.read
      file.write(contents)
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_new
      obj = S3.put_object(
               acl: "public-read",
               bucket: @bucketName,
               key: key_name,
               body: contents
               )
          
          if !obj.blank?
            ext =  file_new.split('.').last.downcase 
            check = Image.find_by_name(file_new)
            if check && check.loan_id == loan.id
              image = check
            else
              image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_new, :url=>"https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan.id}/#{file_new}");
            end
            image.featured = false
            image.save()
            output['files'].push({:name=>file_new, :success=>'Upload was successful!'})
          end    
       
     end 
   end
    render json: output
    return
  end


   def upload_image
   loan=Loan.find_by_id(params[:id].to_i)
  if (loan.info['added_by'].blank?)
      Rails.logger.info "User added by is blank, finding user by email"
      if(loan.email.blank?)
        Rails.logger.info "Loan.email does not exists, means it came from some other source, adding documents to Admin's S3 Bucket"
        uInfo = nil;
      else
        uInfo = User.find_by_email(loan.email)
      end

   else
      Rails.logger.info "User added by exists, so getting userinfo from that"
      uInfo = User.find_by_id(loan.info['added_by'])

   end

   Rails.logger.info "User information #{uInfo.inspect}"
   if(uInfo.nil?)
  
    @bucketName = S3_BUCKET_NAME
  
  else
    # || uInfo.bucket_name.nil?
    @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

  end


   files =  params[:files]
   output = Hash.new
   output['files']=Array.new
   
   files.each do |file_io|
     ext = Rack::Mime::MIME_TYPES.invert["#{file_io.content_type}"]
   file_new = "img_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+ext
     # file_name=file_io.original_filename
     
     File.open(Rails.root.join('public', 'temp', file_new), 'wb') do |file|
        
      contents = file_io.read
      file.write(contents)
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_new
      obj = S3.put_object(
               acl: "public-read",
               bucket: @bucketName,
               key: key_name,
               body: contents
               )
          
          if !obj.blank?
            ext =  file_new.split('.').last.downcase 
            check = Image.find_by_name(file_new)
            if check && check.loan_id == loan.id
              image = check
            else
              image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_new, :url=>"https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan.id}/#{file_new}");
            end
            image.featured = false
            image.save()
            output['files'].push({:name=>file_new, :success=>'Upload was successful!'})
          end    
       
     end 
   end
    render json: output
    return
  end


   def upload_edit_image
   loan=Loan.find_by_id(params[:id].to_i)
   files =  params[:files]
   output = Hash.new
   output['files']=Array.new
   
   files.each do |file_io|
     ext = Rack::Mime::MIME_TYPES.invert["#{file_io.content_type}"]
   file_new = "img_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+ext
     # file_name=file_io.original_filename
     @bucketName = S3_BUCKET_NAME
     File.open(Rails.root.join('public', 'temp', file_new), 'wb') do |file|
        
      contents = file_io.read
      file.write(contents)
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_new
      obj = S3.put_object(
               acl: "public-read",
               bucket: @bucketName,
               key: key_name,
               body: contents
               )
          
          if !obj.blank?
            ext =  file_new.split('.').last.downcase 
            check = Image.find_by_name(file_new)
            if check && check.loan_id == loan.id
              image = check
            else
              image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_new, :url=>"https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan.id}/#{file_new}");
            end
            image.featured = false
            image.save()
            output['files'].push({:name=>file_new, :success=>'Upload was successful!'})
          end    
       
     end 
   end
    render json: output
    return
  end

  def loan_images
    @images = Image.all(:loan_id => params[:id].to_i)
    render partial: 'thumbnails', locals:{images: @images, loan_id: params[:id].to_i}
  end

  def edit_loan_images
    @images = Image.all(:loan_id => params[:id].to_i)
    render partial: 'edit_thumbnails', locals:{images: @images, loan_id: params[:id].to_i}
  end




  def delete_image
    if params[:id]
      img = Image.find_by__id(params[:id])
        # begin
          # Infusionsoft.file_replace(img.file_id.to_i, '')
        # rescue Exception
        # end
      #remove from aws s3
      if !img.blank?
        S3.delete_object(
          bucket: S3_BUCKET_NAME,
          key: img.file_id.to_s,
        )
        
        img.delete
      end
    end
      
      render plain: ''
      
  end

  def edit_delete_image
    if params[:id]
      img = Image.find_by__id(params[:id])
        # begin
          # Infusionsoft.file_replace(img.file_id.to_i, '')
        # rescue Exception
        # end
      #remove from aws s3
      if !img.blank?
        S3.delete_object(
          bucket: S3_BUCKET_NAME,
          key: img.file_id.to_s,
        )
        
        img.delete
      end
    end
      
      render plain: ''
      
  end



  def upload_doc
   loan=Loan.find_by_id(params[:id].to_i)
   # check = loan.info['added_by'].blank?
   # abort("#{loan.inspect}")
   uInfo = nil;

   if (loan.info['added_by'].blank?)
      Rails.logger.info "User added by is blank, finding user by email"
      if(loan.email.blank?)
        Rails.logger.info "Loan.email does not exists, means it came from some other source, adding documents to Admin's S3 Bucket"
        uInfo = nil;
      else
        uInfo = User.find_by_email(loan.email)
      end

   else
      Rails.logger.info "User added by exists, so getting userinfo from that"
      uInfo = User.find_by_id(loan.info['added_by'])

   end

   Rails.logger.info "User information #{uInfo.inspect}"
   if(uInfo.nil?)
  
    @bucketName = S3_BUCKET_NAME
  
  else
    # || uInfo.bucket_name.nil?
    @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

  end

   # abort("#{uInfo.inspect}")
   # if defined? loan.info['added_by']
      # uInfo = User.find_by_id(loan.info['added_by'])
      # abort("#{uInfo}")
      # if(uInfo.bucket_name.blank?)
      #   @bucketName = S3_BUCKET_NAME
      #  else 
        # if defined? uInfo.bucket_name && uInfo.bucket_name!= nil
        # Rails.logger.info "Common Bucket name is #{S3_BUCKET_NAME}"
        # Rails.logger.info "The user fetched is #{uInfo.inspect}"
        # if uInfo.bucket_name.blank?
        #     @bucketName = uInfo.bucket_name
        # else
        #     @bucketName = S3_BUCKET_NAME
        # end 
      # end  
   # end
   Rails.logger.info "Bucket name defined is #{@bucketName}"
   files =  params[:files]
   output = Hash.new
   output['files']=Array.new
   #fsize =  number_to_human_size(files.size)
   #abort("#{fsize}")
   
   files.each do |file_io|
    #abort("#{file_io.inspect}")
    extension = File.extname(file_io.original_filename)
   fsize =  number_to_human_size(file_io.size)
   fname = File.basename(file_io.original_filename, extension) 
    
    #new_filename = file_io.original_filename+"_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")
    new_filename = fname+"_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+extension
    #abort("#{new_filename}")


     File.open(Rails.root.join('public', 'temp', new_filename), 'wb') do |file|
        
      contents = file_io.read
      base64Contents = Base64.encode64(contents)
      file.write(contents)
        
         output['files'].push({:name=>new_filename, :success=>'Upload was successful!'})
          #check each image and see if it is already in infusionsoft
          @check = false
          loan.get_docs.each do |img|
            fields = ['Id']
            if new_filename == img.name
              @check = img
            end
          end
          
          if @check==false
            # @isFile = Infusionsoft.file_upload(params[:id].to_i, file_io.original_filename, base64Contents)
             # ext =  file_io.original_filename.split('.').last.downcase
             key_name = loan.id.to_s+'/'+new_filename
              obj = S3.put_object(
                       acl: "public-read",
                       bucket: @bucketName,
                       key: key_name,
                       body: contents
                       ) 
              doc = Document.new(:loan_id=>loan._id, :name=>new_filename, :category=>params[:category], :url=>"https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan.id}/#{new_filename}");
              doc.save()
          end    
       
     end 
   end
    render json: output
    return    
  end

   def upload_file
   loan=Loan.find_by_id(params[:id].to_i)
   files =  params[:files]
   output = Hash.new
   output['files']=Array.new
   
   
   files.each do |file_io|
    #abort("#{file_io.inspect}")
    extension = File.extname(file_io.original_filename)
    fname = File.basename(file_io.original_filename, extension) 
    #new_filename = file_io.original_filename+"_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")
    new_filename = fname+"_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+extension
    #abort("#{new_filename}")


     File.open(Rails.root.join('public', 'temp', new_filename), 'wb') do |file|
        
      contents = file_io.read
      base64Contents = Base64.encode64(contents)
      file.write(contents)
        
         output['files'].push({:name=>new_filename, :success=>'Upload was successful!'})
          #check each image and see if it is already in infusionsoft
          @check = false
          loan.get_docs.each do |img|
            fields = ['Id']
            if new_filename == img.name
              @check = img
            end
          end
          
          if @check==false
            # @isFile = Infusionsoft.file_upload(params[:id].to_i, file_io.original_filename, base64Contents)
             # ext =  file_io.original_filename.split('.').last.downcase 
              
              
              doc = FolderFile.new
              doc.loan_id = params[:id]
              doc.name = new_filename
              unless current_user.blank?
                doc.user_id = current_user.id
              end
              doc.custom_folder_id = params[:folder]
              doc.save()
          end    
       
     end 
   end
    render json: output
    return    
  end


  def view_doc
    doc = Document.find_by_id(params[:id])
    #abort("#{doc.inspect}")
    #begin
     # contents = Infusionsoft.file_get(doc['file_id'])
      #abort("#{contents.inspect}")
    #rescue
     #   flash[:alert] ='The document you selected is not available.'
      #  redirect_to '/'
       # return;
    # end
    
    if doc.blank?
        flash[:alert] ='The document you selected is not available.'
        redirect_to '/'
        return;     
    end
    
    #decodedContents = Base64.decode64(contents); 
    #abort("#{decodedContents}")
    fileName = Rails.root.join('public', 'temp', doc[:name])
    #File.open(fileName, 'wb') { |f| f.write(decodedContents) }
    send_file fileName
    return
  end

  def view_file
    doc = FolderFile.find_by_id(params[:id])
    #abort("#{doc.inspect}")
    #begin
     # contents = Infusionsoft.file_get(doc['file_id'])
      #abort("#{contents.inspect}")
    #rescue
     #   flash[:alert] ='The document you selected is not available.'
      #  redirect_to '/'
       # return;
    # end
    
    if doc.blank?
        flash[:alert] ='The document you selected is not available.'
        redirect_to '/'
        return;     
    end
    
    #decodedContents = Base64.decode64(contents); 
    #abort("#{decodedContents}")
    fileName = Rails.root.join('public', 'temp', doc[:name])
    #File.open(fileName, 'wb') { |f| f.write(decodedContents) }
    send_file fileName
    return
  end


  def update
    @loan = @loan = Loan.find_by_id(params[:id].to_i)
    @loan.allowed_emails = params[:loan][:allowed_emails]
    @loan.save
    flash[:notice] = "Allowed Emails updated successfully"    
    redirect_to :action => "show", :id => params[:id]
    
  end



  def reset_url
    @loan = @loan = Loan.find_by_id(params[:id].to_i)
    @loan.url = Digest::MD5.hexdigest('funding'+@loan._id.to_s+Time.now.getutc.to_s)
    @loan.save
    host = request.host || "http://fundingdatabase.com"
    render plain: host+'/loans/'+@loan.url
  end
 
  
  def get_url
    @loan = @loan = Loan.find_by_id(params[:id].to_i)
    if @loan.url.blank?
      @loan.url =  Digest::MD5.hexdigest('funding'+@loan._id.to_s+Time.now.getutc.to_s)
      @loan.save
    end
    host = request.host || "http://fundingdatabase.com"
    render plain: host+'/loans/'+@loan.url
  end
 

  def nda_signed
    @loan = Loan.find_by_id(params[:id].to_i)
    if params[:name].blank? || params[:email].blank?
      flash[:alert] = "All fields are required"
      render 'show'
      return
    end
    
    if @loan.allowed_emails.include? params[:email]

      if @loan.ndas.blank?
        nda = Nda.new
        nda.loan_id = params[:id].to_i
        nda.name = params[:name]
        nda.email = params[:email]
        nda.date = Time.now
        nda.save
      else
        nda = Nda.find_by_email(params[:email])
        if nda.blank?
          nda = Nda.new
          nda.loan_id = params[:id].to_i
          nda.name = params[:name]
          nda.email = params[:email]
          nda.date = Time.now
          nda.save  
        end
      end 
      @loan.nda_signed = true
    else
      flash[:alert] = "You are not on the list of approved emails. If you would like access to this loan please send an email to administrator@fundingdatabase.com."
    end   
   
    render 'show' 
  end


   def archived_refresh
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
    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
           @broker_emails << broker_req['email']
        end
      end
      @total_loans = Loan.count(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true);
      @loans = Loan.paginate(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
    else
      @total_loans = Loan.count(:delete.ne => 1, :archived.ne => true);
      @loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
    end
      unless params[:records].blank?
      @partition = @total_loans/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = params[:records]
      @page = params[:page]
    else
      @partition = @total_loans/ 10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end

     flash.now[:notice] = "Loans are archived successfully"
     render partial: 'loans/all_loans'
  end

  
  def archive
    ids = params[:ids].split(",")
    ids.each do |id|
      @loan = Loan.find_by_id(id.to_i)
      @loan.archived = true
      @loan.save
    end
    #Infusionsoft.contact_add_to_group(@loan.id, 282)
    archived_refresh
    flash.now[:notice] = "Loans are archived successfully"
   # render plain: 'Archived!'
    #redirect_to :action =>"index", :id=>@loan.id    
  end

  def docs
    #redirect_to action: 'detail', id: params[:id]
    @fileUpload = "true"
    id = Base64.decode64(Base64.decode64(params[:id])) 
    # abort("#{id}")
    loan_url = Loan.find_by_id(id.to_i)

    if loan_url
      @loan = loan_url
    end



    time = @loan.url_time
    if time.month == 12
      next_month = Time.utc(time.year+1, 1, time.day)
    else
      next_month = Time.utc(time.year, time.month+1, time.day)
    end 
    endDate = next_month.strftime('%Y-%m-%d')
    
    today = Time.now.getutc
    todayDate = today.strftime('%Y-%m-%d')
    
    if endDate < todayDate
        flash[:alert] ='Page has been expired.'
        redirect_to '/'
        return;    
    end

    if @loan.blank? 
      @loan = Loan.find_by_id(params[:id].to_i)
    end

   dateField = ['_ExpectedCloseDate', '_AppraisalDate', 'Birthday', 'DateCreated', 'LastUpdated']

    if @loan.blank?
     
      @loan = Loan.new
      @loan.name=contact['_LoanName']
      @loan._id = contact['Id']
      @loan.info = contact
      @images = @loan.images
      @documents = @loan.get_docs
      @loan.save()
    
    else
      begin
        
      rescue Exception
        flash[:alert] ='You selected an invalid loan.'
        redirect_to '/'
        return;
      end
      
      
      @images = @loan.images
      @documents = @loan.get_docs
      @loan.save()
    
    end

    @folders = CustomFolder.all(:loan_id => @loan.id.to_i)
  end

 def recent actn=nil
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
    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
          unless broker_req.blank?
           @broker_emails << broker_req['email'] 
          end
        end
      end
      @total_loans = Loan.count(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
       @total_loans = Loan.count(:delete.ne => 1, :archived.ne => true);

       @loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
       # abort("#{@total_loans}")
    end
    
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
    end

    unless params[:records].blank?
      @partition = @total_loans/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = params[:records]
      @page = params[:page]
    else
      @partition = @total_loans/ 10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end
     if actn == "delete"
        flash.now[:notice] = "Loans are deleted successfully"
     elsif actn == "shop_loan"
        flash.now[:notice] = "Your shop loan request has been sent successfully" 
     else
        flash.now[:notice] = "Sorting by recent Loans"
     end
     render partial: 'loans/all_loans'
  end


  # def priority actn=nil
  #     #################### Check Login #######################
  #   roles=current_user.roles
  #   @names = Array.new
  #   roles.each do |role|
  #     @names << role.name
  #   end
  #   @checkAdmin = @names.include?('Admin')
  #   @checkBroker = @names.include?('Broker')
  #   if @checkBroker!=true
  #    # authorize Loan
  #   end
  #   #################### End Check Login #######################

  #   if @checkAdmin!=true && @checkBroker==true
  #     @broker_emails = Array.new
  #     broker= Broker.find_by_email(current_user.email)
  #     brokId=broker.id.to_s
  #     @broker_emails << broker['email']
  #     reqs = Request.all(:broker_id => brokId, :status =>1)
  #     unless reqs.blank?
  #       reqs.each do |req|
  #         broker_req = Broker.find(req.subbroker_id)
  #         unless broker_req.blank?
  #          @broker_emails << broker_req['email']
  #         end
  #       end
  #     end
  #     @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :sort_id.asc) 
  #   else
  #     #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10)
  #     @loans = Loan.all(:delete.ne => 1, :archived.ne => true, :order => :sort_id.asc)
  #   end
    
  #   @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
  #   @shop_ids = Array.new
  #   @shopLoans.each do |sloan|
  #     @shop_ids << sloan.loan_id
  #   end

  #    if actn == "delete"
  #     flash.now[:notice] = "Loans are deleted successfully"
  #    elsif actn == "shop_loan"
  #     flash.now[:notice] = "Your shop loan request has been sent successfully"
  #    else
  #     flash.now[:notice] = "Sorting by priority"
  #    end
  #    render partial: 'loans/sort_loans'
  # end


  def priority actn=nil
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

    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
          unless broker_req.blank?
           @broker_emails << broker_req['email']
          end
        end
      end
      @total_loans = Loan.count(:on_priority=>1, :email =>@broker_emails, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:on_priority=>1, :email =>@broker_emails, :delete.ne => 1, :archived.ne => true , :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :priority_num.asc) 
    else
      @total_loans = Loan.count(:on_priority=>1, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:on_priority=>1, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :priority_num.asc)
    end
    
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
    end

    unless params[:records].blank?
      @partition = @total_loans/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = params[:records]
      @page = params[:page]
    else
      @partition = @total_loans/ 10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end

     if actn == "delete"
      flash.now[:notice] = "Loans are deleted successfully"
     elsif actn == "shop_loan"
      flash.now[:notice] = "Your shop loan request has been sent successfully"
     else
      flash.now[:notice] = "Sorting by priority"
     end
     render partial: 'loans/sort_loans'
  end

  ####################### Incomplete Loan ##################################

    def incomplete_loan actn=nil
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

    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
          unless broker_req.blank?
           @broker_emails << broker_req['email']
          end
        end
      end
      @total_loans = Loan.count(:incomplete=>1, :email =>@broker_emails, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:incomplete=>1, :email =>@broker_emails, :delete.ne => 1, :archived.ne => true , :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :id.desc) 
    else
      @total_loans = Loan.count(:incomplete=>1, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:incomplete=>1, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :id.desc)
    end
    
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
    end

    unless params[:records].blank?
      @partition = @total_loans/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = params[:records]
      @page = params[:page]
    else
      @partition = @total_loans/ 10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total_loans
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end

     if actn == "delete"
      flash.now[:notice] = "Loans are deleted successfully"
     elsif actn == "shop_loan"
      flash.now[:notice] = "Your shop loan request has been sent successfully"
     else
      flash.now[:notice] = "Sorting by incomplete loans."
     end
     render partial: 'loans/all_loans'
  end


  ####################### Incomplete Loan ##################################

  def changeorder
    @loan_ids=params[:moredata].split(",").map { |s| s.to_i }
    x=1
    @loan_ids.each do |number|
      loanRecord=Loan.find(number)
      loanRecord.priority_num=x
      loanRecord.save
      x += 1  
    end
    render nothing: true
  end

  # def add_to_priority
  #   user_id = current_user.id
  #   loan_id = params['loan_id']
  #   @priority = PriorityLoan.new
  #   @priority.loan_id = loan_id
  #   @priority.user_id = user_id
  #   @priority.save

  #   render text: "done"
  # end

  def add_to_priority
    user_id = current_user.id
    loan_id = params['loan_id']
    @priority = Loan.find_by_id(loan_id.to_i)
    @priority.on_priority = 1
    @priority.save

    render text: "done"
  end

  def remove_priority
    user_id = current_user.id
    loan_id = params['loan_id']
    @priority = Loan.find_by_id(loan_id.to_i)
    @priority.on_priority = 0
    @priority.save

    render text: "done"
  end

   

  def generate_pdfs
    ids=params[:moredata].split(",").map { |s| s.to_i }
    require "prawn"
    time="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
    Prawn::Document.generate("pdfs/"+time+".pdf") do

     #Prawn::Document.generate("public/pdfs/"+time+".pdf") do

    @loans = Loan.find(ids)
      @loans.map do |loan| 
       a=""
        unless loan.info['City3'].blank?
          a += loan.info['City3']
        end
        unless loan.info['State3'].blank?
          a += ", "+ loan.info['State3']
        end

        unless loan.info['_NetLoanAmountRequested0'].blank?
          amnt="$ "+loan.info['_NetLoanAmountRequested0'].to_s
        else
          amnt="N/A"
        end

        unless loan.info['_LoanSummaryWhatareyoulookingfor'].blank?
          summary=loan.info['_LoanSummaryWhatareyoulookingfor']
        else
          summary=""
        end
      loans =  [["<b>"+loan.name+" | "+a+"\n Loan Amount: </b>"+amnt+"\n <b>Summary: </b>"+summary]] 
      table loans
      end
   

    end
    pdf_filename =  time+".pdf"
    send_data(pdf_filename, :filename => "your_document.pdf", :type => "application/pdf")
  end

def generate_pdf
  ids=params[:moredata].split(",").map { |s| s.to_i }
  today=Time.new
  str_time=today.strftime("%d/%m/%Y")
   time="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")+".pdf"
    # file_path = "public/pdfs/"+time+".pdf"
  text="<div style='width:100%'><img src='http://#{@hostname}/assets/idealview-logo-2c6b9989b6877f38ebd24059a00f91e4.png' style='width:250px; float:left;'><p style='float:right;'>Pipeline Summary "+str_time+"</p></div>"
  @loans = Loan.find(ids)
  @loans.map do |loan|
    a=""
    unless loan.info['City3'].blank?
      a += loan.info['City3']
    end
    unless loan.info['State3'].blank?
      a += ", "+ loan.info['State3']
    end

    if a==""
      a="N/A"
    end

    unless loan.info['_NetLoanAmountRequested0'].blank?
      amnt="$ "+loan.info['_NetLoanAmountRequested0'].to_s
    else
      amnt="N/A"
    end

    unless loan.info['_LoanSummaryWhatareyoulookingfor'].blank?
      summary=loan.info['_LoanSummaryWhatareyoulookingfor']
     # summary=sentence.summary! '"',''
    else
      summary=""
    end

    #text +="<div style='width:94%; border: 2px solid black; text-align:left; float:left; margin-left:10px; padding-left:10px; padding-right:10px; padding-bottom:25px; margin-bottom:25px; white-space: pre; word-wrap: break-word; -webkit-hyphens: auto;-moz-hyphens: auto; hyphens: auto;'><br><b>"+loan.name+" | "+a+"</b><br><b>Loan Amount : </b>"+amnt+"<br><br><b>Summary : </b>"+summary+"<br></div><br><br><br><br>"
    text +="<div style='width:94%; border: 2px solid black; text-align:left; float:left; margin-left:10px; padding-left:10px; padding-right:10px; padding-bottom:25px; margin-bottom:25px;'><br><b>"+loan.name+" | "+a+"</b><br><b>Loan Amount : </b>"+amnt+"<br><br><b>Summary : </b>"+summary+"<br></div><br><br><br><br>"

  end
     pdf = WickedPdf.new.pdf_from_string(text, encoding: "UTF-8")
    save_path = Rails.root.join('pdfs',time)
    File.open(save_path, 'wb') do |file|
     file << pdf
    end
    # render nothing: true
     pdf_filename =  time
    send_data(pdf_filename, :filename => "your_document.pdf", :type => "application/pdf")
end

def generate_pdf_old
 ids=params[:moredata].split(",").map { |s| s.to_i }
  today=Time.new
  str_time=today.strftime("%d/%m/%Y")
  text="<div style='width:100%'><img src='http://#{@hostname}/assets/idealview-logo-2c6b9989b6877f38ebd24059a00f91e4.png' style='width:250px; float:left;'><p style='float:right;'>Pipeline Summary "+str_time+"</p></div>"
  @loans = Loan.find(ids)
  @loans.map do |loan|
    a=""
    unless loan.info['City3'].blank?
      a += loan.info['City3']
    end
    unless loan.info['State3'].blank?
      a += ", "+ loan.info['State3']
    end

    if a==""
      a="N/A"
    end

    unless loan.info['_NetLoanAmountRequested0'].blank?
      amnt="$ "+loan.info['_NetLoanAmountRequested0'].to_s
    else
      amnt="N/A"
    end

    unless loan.info['_LoanSummaryWhatareyoulookingfor'].blank?
      summary=loan.info['_LoanSummaryWhatareyoulookingfor']
     # summary=sentence.summary! '"',''
    else
      summary=""
    end

    text +="<div style='width:98%; border: 2px solid black; text-align:left; float:left; margin-left:10px; padding-left:10px; padding-bottom:25px; margin-bottom:25px;'><br><b>"+loan.name+" | "+a+"</b><br><b>Loan Amount : </b>"+amnt+"<br><br><b>Summary : </b>"+summary+"<br></div><br><br><br><br>"
  end

    kit = PDFKit.new(text)
    time="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
    #file_path = "public/pdfs/"+time+".pdf"
    file_path = "pdfs/"+time+".pdf"
    pdf = kit.to_file file_path
    pdf_filename =  time+".pdf"
    send_data(pdf_filename, :filename => "your_document.pdf", :type => "application/pdf")
  end

 def show_pdf
   send_file 'pdfs/'+params[:id]+'.pdf', :type => 'application/pdf'
 end

 def pdf
  today=Time.new
  str_time=today.strftime("%d/%m/%Y")
  file_name="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
  dbPdf=Pdf.new()
  dbPdf.file_name=file_name
  dbPdf.date_created=today
  dbPdf.save
  last_id=dbPdf.id
  
  sort=1
  params[:q].map do |id|
   l_id=id.to_i
   @loan = Loan.find_by_id(l_id)
    a=""
    if defined? @loan.info['City3']
      unless @loan.info['City3'].blank?
        a += @loan.info['City3']
      end
    end
    if defined? @loan.info['State3']
      unless @loan.info['State3'].blank?
        a += ", "+ @loan.info['State3']
      end
    end

    if a==""
      a="N/A"
    end
    if defined? @loan.info['_NetLoanAmountRequested0']
      unless @loan.info['_NetLoanAmountRequested0'].blank?
        amnt="$ "+@loan.info['_NetLoanAmountRequested0'].to_s
      else
        amnt="N/A"
      end
    end

    if defined? @loan.info['_LoanSummaryWhatareyoulookingfor']
      unless @loan.info['_LoanSummaryWhatareyoulookingfor'].blank?
        summary=@loan.info['_LoanSummaryWhatareyoulookingfor']
        
       # summary=sentence.summary! '"',''
      else
        summary=""
      end
    end

   dbrec=LoanPdf.new()
   dbrec.pdf_id=last_id
   dbrec.loan_id=@loan.id
   dbrec.loan_name=@loan.name
   dbrec.location=a
   dbrec.amount=amnt
   dbrec.summary=summary
   dbrec.sort_id=sort
   dbrec.save
   #abort("#{dbrec.inspect}")
   sort += 1
 end
 redirect_to :action => "edit_pdf", :id => last_id
  
end

def edit_pdf
  @lenders=LoanUrl.all
  #abort("#{@lenders}")
  @emails=Array.new
  @lenders.each do |lender|
    @emails<<lender.email
  end 
  @all_emails=@emails.uniq
  pdfId=params[:id]
  @record=Pdf.find(pdfId)
  @pdfs=@record.pdf_by_loan
  today=Time.new
  @str_time=today.strftime("%d/%m/%Y")
  @file_name="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
  if @record.emails.blank?
 else
    @email_select=@record.emails.split(', ')
    @email_select.each do |select_email|
      @all_emails.delete(select_email)
    end
  end
end

def generate_html
  #abort("#{params}")
  if params[:fname]!=""
    filename=params[:fname]
  else
    filename="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
  end

  IO.write('/tmp/'+filename+'.html', params[:content])

  

   pdf = WickedPdf.new.pdf_from_html_file('/tmp/'+filename+'.html')
  # pdf = WickedPdf.new.pdf_from_html_file('test..')
  time="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
  # then save to a file
  save_path = Rails.root.join('pdfs',filename+'.pdf')
  #save_path = Rails.root.join('pdfs','loans_'+time+'.pdf')
  File.open(save_path, 'wb') do |file|
    file << pdf
  end
   pdfInfo = Pdf.find_by_id(params[:pdfId])
   pdfInfo.file_name = filename
   pdfInfo.name=filename
   unless  params[:emails].blank?
      pdfInfo.emails = params[:emails].join(", ")
   end
   pdfInfo.content = params[:loans]
   pdfInfo.save
   pdf_filename =  filename+".pdf"
   send_data(pdf_filename, :filename => "your_document.pdf", :type => "application/pdf")
   #redirect_to :action => "pdf_files", :id => "listing"
end



def hide_file
  @doc_id=params[:id]
  doc = Document.find(@doc_id)
  doc.hide = 1
  doc.save
  render nothing: true
 end

 def hide_doc
  @file_id=params[:id]
  doc = FolderFile.find(@file_id)
  doc.hide = 1
  doc.save
  render nothing: true
 end

 def show_file
  @doc_id=params[:id]
  doc = Document.find(params[:id])
  doc.hide = 0
  doc.save
  render nothing: true
 end

 def show_doc
  @doc_id=params[:id]
  doc = FolderFile.find(@doc_id)
  doc.hide = 0
  doc.save
  render nothing: true
 end

  def del_file
  @doc_id=params[:id]
  doc = Document.find(@doc_id)
  doc.delete = 1
  doc.save
  render nothing: true
 end

 def del_doc
  @doc_id=params[:id]
  doc = FolderFile.delete(@doc_id)
  #doc.delete = 1
  #doc.save
  render nothing: true
 end


 def del_folder
  @folder_id=params[:id]
  CustomFolder.delete(@folder_id)
  FolderFile.delete_all(:custom_folder_id => @folder_id)
  render nothing: true
 end

 def send_to_cpc
  require 'net/http'
  require 'uri'
  ids = params[:moredata]
  all_ids=ids.split(",").map { |s| s.to_i }
  
  all_ids.each do |id|
    @loans = Loan.find(id)
    uri = URI.parse('https://diversified.cacheprivatecapital.com/index.php?r=sls/realin/index');
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(@loans['info'])
    response = http.request(request)
  end

   #contact['cpc_id']=response.body
   #@loans.info = contact
   #@loans.save()
  #render :json => "Sent"
  render plain: 'Success!'
 end

def send_to_ids


  ids = params[:moredata]
  all_ids=ids.split(",").map { |s| s.to_i }
  rsponse = Array.new
  all_ids.each do |id|
    @loans = Loan.find(id)
    @borrowers = @loans.borrower
    @collaterals = @loans.collateral
    @funds = @loans.use_of_fund
    uname = current_user.ids_username

    myHash = Hash.new
    myHash['username'] = uname
    myHash['loan_id'] = @loans.id
    myHash['loan'] = @loans.info
    myHash['borrowers'] = @borrowers
    myHash['collaterals'] = @collaterals
    myHash['funds'] = @funds

    # abort("#{myHash.inspect}")
    uri = URI.parse("https://#{uname}.idealsuite.com/index.php?r=sls/realin/index")

    # Full control
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"data" => myHash})
    response = http.request(request)
    rsponse << response.body
  end

  # abort("#{rsponse.inspect}")
   
  render plain: 'Success!'
 end

 def application
    #  user = User.find_by_id('54c6abebdba1d65799000002')
    #    params = {
    #   :body     => 'body',
    #   :to       => 'to',
    #   :subject  => 'subject',
    #   :from     => 'from',
    #   :user_id  => user.id
    # }
    #  message = Message.new(params);
    # unless message.save
    #   abort("OOPS")
    # end

    if !@infoBroker.blank? 
      if @infoBroker.plan == "SOLO"
        loans = Loan.all(:email => @infoBroker.email)
        @num = loans.count
      elsif @infoBroker.plan == "BUSINESS"
        loans = Loan.all(:email => @infoBroker.email)
        @num = loans.count
      end
    end
    roles=current_user.roles
    @names = Array.new
    roles.each do |role|
      @names << role.name
    end
    @checkAdmin = @names.include?('Admin')
    @checkBroker = @names.include?('Broker')
   
  
 end

   def edit_application

    @loan = Loan.find_by_id(params['id'].to_i)
    @borrowers = Borrower.all(:loan_id => params['id'].to_i)
    @collaterals = Collateral.all(:loan_id => params['id'].to_i)
    @funds = UseOfFund.all(:loan_id => params['id'].to_i)
    @images = @loan.images
    @folders = CustomFolder.all(:loan_id => @loan.id.to_i)
    # abort("#{@folders.inspect}")
    ############### Uploading Condition ######################

        uInfo = User.find_by_id(@loan.info['added_by'])
         if !uInfo.blank?
            
           if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

              @bucketName = uInfo.bucket_name
              resp = S3.list_objects(bucket: "#{@bucketName}")
              @bucket_size = 0
              resp.contents.each do |object|
                @bucket_size = @bucket_size+object.size
              end
              if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
                #@max_size = 10022482
                @max_size = 1073741824
                if @bucket_size < @max_size
                  @fileUpload = "true"
                else
                  @fileUpload = "false"
                end
              elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
                
                @max_size = 5368709120
                if @bucket_size < @max_size
                  @fileUpload = "true"
                else
                  @fileUpload = "false"
                end
              else
                @fileUpload = "true"
              end
            else
                @bucketName = S3_BUCKET_NAME
                @fileUpload = "true"
            end
          else
            uInfo = User.find_by_email(@loan.email)
            if !uInfo.blank?
              if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

              @bucketName = uInfo.bucket_name
              resp = S3.list_objects(bucket: "#{@bucketName}")
              @bucket_size = 0
              resp.contents.each do |object|
                @bucket_size = @bucket_size+object.size
              end
              if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
                #@max_size = 10022482
                @max_size = 1073741824
                if @bucket_size < @max_size
                  @fileUpload = "true"
                else
                  @fileUpload = "false"
                end
              elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
                
                @max_size = 5368709120
                if @bucket_size < @max_size
                  @fileUpload = "true"
                else
                  @fileUpload = "false"
                end
              else
                @fileUpload = "true"
              end
            else
                @bucketName = S3_BUCKET_NAME
                @fileUpload = "true"
            end
            end
          end

          if !@adminLogin.blank?
              @fileUpload = "true"
          end

    ############### End Uploading Condition ##################
      
   end



   def create_application
    
    collaterals  = params[:collateral]
    params.delete :action
    params.delete :controller     
    
    @last_loan = Loan.last
    @new_id = @last_loan.id+1

    dbLoan = Loan.new()
    if params[:_LoanName].blank?
      dbLoan.name = 'Awesome Loan Name'
    else
      dbLoan.name=params[:_LoanName]
    end
    unless params[:Email].blank?
      dbLoan.email = params[:Email]
    end

    userInfo = User.find_by_email("#{params[:current_user_email]}")
    userInfo.roles.each do |role|
      if dbLoan.created_by_info.blank?
        if role.name == "Admin"
          dbLoan.created_by_info = "Admin"
        elsif current_user.is_admin == true
          dbLoan.created_by_info = "Admin"
        elsif role.name == "Broker"
          dbLoan.created_by_info = "Broker"
        else
          dbLoan.created_by_info = "Broker"
        end
      end
    end
    unless userInfo.email.blank?
      dbLoan.created_by_email = userInfo.email
    end
    unless userInfo.name.blank?
      dbLoan.created_by_name = userInfo.name
    end
    dbLoan.id = @new_id

    borrowers = params[:borrower]
    borrower_types = borrowers[:borrower_type]
    bornum = 0

    bgrantr = ""
    borrower_types.each do |borrower_type|
      ############### If contact form empty ######################
       
        if params[:Email].blank?
          if bgrantr!="yes"
            if params[:borrower][:borrower_guarantor][bornum] == "Yes"
              params[:Email] = params[:borrower][:personal_email][bornum]
              params[:FirstName] = params[:borrower][:personal_name][bornum]
              params[:Phone] = params[:borrower][:personal_phone][bornum]
              dbLoan.email = params[:borrower][:personal_email][bornum]
              bgrantr="yes"
            end
          end
        end

      bornum = bornum+1
      ################ End If contact form empty #################
    end
    # abort("#{params.inspect}")
    params.each do |key, value| 
      if value.include? "$"
        if key == "_NetLoanAmountRequested0"
          params[key] = value.sub('$', '')
        elsif key == "original_purchase_price"
          params[key] = value.sub('$', '')
        elsif key == "cash_contributed"
          params[key] = value.sub('$', '')
        elsif key == "rehab_amount"   
          params[key] = value.sub('$', '') 
        end  
      end
      if value.include? ","
        if key == "_NetLoanAmountRequested0"
          params[key] = value.gsub(',', '')
        elsif key == "original_purchase_price"
          params[key] = value.gsub(',', '')
        elsif key == "cash_contributed"
          params[key] = value.gsub(',', '')
        elsif key == "rehab_amount"   
          params[key] = value.gsub(',', '') 
        end  
      end

    end

    time_nw = Time.now
    dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
    dbLoan.created_at=Time.now
    dbLoan.id = @new_id
    dbLoan.save

    amount = params[:amount]
    uses = params[:use]
    is_free_related = params[:is_free_related]
    beneficiary = params[:beneficiary]
    maturityDate = params[:maturityDate]
    stats = params[:stats]
    contractDate = params[:contractDate]
    earnedDeposit = params[:earnedDeposit]

    ############## Use Of Fund #####################
    if !uses.blank?
      num = 0
      uses.each do |fuse|
        fundInfo = UseOfFund.new
        fundInfo.loan_id = dbLoan.id
        fundInfo.use = fuse
        unless params[:is_free_related].blank?
          fundInfo.is_free_related = is_free_related[num]
        end
        
        if amount[num].include? "$"
          amount[num] = amount[num].sub('$', '')
        end

        if amount[num].include? ","
          amount[num] = amount[num].sub(',', '')
        end
        
        fundInfo.amount = amount[num]
        fundInfo.beneficiary = beneficiary[num]
        if fuse=="Payoff"
          fundInfo.maturityDate = maturityDate[num]
          fundInfo.stats = stats[num]
        elsif fuse == "Purchase"
          fundInfo.contractDate = contractDate[num]
          if earnedDeposit[num].include? "$"
           earnedDeposit[num] = earnedDeposit[num].sub('$', '')
          end
          if earnedDeposit[num].include? ","
           earnedDeposit[num] = earnedDeposit[num].sub(',', '')
          end
          fundInfo.earnedDeposit = earnedDeposit[num]
        end
        fundInfo.save

        num = num+1
      end

    end
    ############## End Use Of Fund #####################

    #################### Collateral ################
    collaterals = params[:collateral]
    asset_types = collaterals[:asset_type]
   
    colnum = 0
    unless collaterals.blank?
      asset_types.each do |asset_type|
        colltrl = Collateral.new
        colltrl.loan_id = dbLoan.id
        colltrl.asset_type = asset_type
        colltrl.address = params[:collateral][:address][colnum]
        colltrl.city = params[:collateral][:city][colnum]
        colltrl.state = params[:collateral][:state][colnum]
        colltrl.postalcode = params[:collateral][:zipcode][colnum]
        colltrl.source_of_value = params[:collateral][:source_of_value][colnum]
        colltrl.collateral_value = params[:collateral][:collateral_value][colnum]
        if params[:collateral][:size][colnum] == "Sq Footage"
          colltrl.sq_footage = params[:collateral][:sizes_val][colnum]
        elsif params[:collateral][:size][colnum] == "Units"
          colltrl.units = params[:collateral][:sizes_val][colnum]
        elsif params[:collateral][:size][colnum] == "Acres"
          colltrl.acres = params[:collateral][:sizes_val][colnum]
        end
        colltrl.size = params[:collateral][:size][colnum]
        colltrl.property_generate_income = params[:collateral][:property_generate_income][colnum]
        if params[:collateral][:noi_ytd][colnum].include? "$"
           params[:collateral][:noi_ytd][colnum] = params[:collateral][:noi_ytd][colnum].sub('$', '')
        end
        if params[:collateral][:noi_ytd][colnum].include? ","
           params[:collateral][:noi_ytd][colnum] = params[:collateral][:noi_ytd][colnum].sub(',', '')
        end
        colltrl.noi_ytd = params[:collateral][:noi_ytd][colnum]
        if params[:collateral][:noi_last_year][colnum].include? "$"
           params[:collateral][:noi_last_year][colnum] = params[:collateral][:noi_last_year][colnum].sub('$', '')
        end
        if params[:collateral][:noi_last_year][colnum].include? ","
           params[:collateral][:noi_last_year][colnum] = params[:collateral][:noi_last_year][colnum].sub(',', '')
        end
        colltrl.noi_last_year = params[:collateral][:noi_last_year][colnum]
        if params[:collateral][:noi_two_years_ago][colnum].include? "$"
           params[:collateral][:noi_two_years_ago][colnum] = params[:collateral][:noi_two_years_ago][colnum].sub('$', '')
        end
        if params[:collateral][:noi_two_years_ago][colnum].include? ","
           params[:collateral][:noi_two_years_ago][colnum] = params[:collateral][:noi_two_years_ago][colnum].sub(',', '')
        end
        colltrl.noi_two_years_ago = params[:collateral][:noi_two_years_ago][colnum]
        colltrl.save

        colnum = colnum+1
      end
    end
    #################### End Collateral ################

    ################### Borrower ######################
    borrowers = params[:borrower]
    borrower_types = borrowers[:borrower_type]
    bornum = 0

    borrower_types.each do |borrower_type|
      ############### If contact form empty ######################
        bgrantr = ""
        if params[:Email].blank?
          if bgrantr!="yes"
            if params[:borrower][:borrower_guarantor][bornum] == "Yes"
              params[:Email] == params[:borrower][:personal_email][bornum]
              params[:FirstName] == params[:borrower][:personal_name][bornum]
              params[:Phone] == params[:borrower][:personal_phone][bornum]
            end
          end
        end

      ################ End If contact form empty #################
      borwr = Borrower.new
      borwr.loan_id = dbLoan.id
      borwr.borrower_type = borrower_type
      borwr.personal_name = params[:borrower][:personal_name][bornum]
      borwr.personal_phone = params[:borrower][:personal_phone][bornum]
      borwr.personal_email = params[:borrower][:personal_email][bornum]
      borwr.personal_address = params[:borrower][:personal_address][bornum]
      borwr.personal_state = params[:borrower][:personal_state][bornum]
      borwr.personal_city = params[:borrower][:personal_city][bornum]
      borwr.personal_postalcode = params[:borrower][:personal_postalcode][bornum]
      borwr.estimated_fico = params[:borrower][:estimated_fico][bornum]
      if params[:borrower][:net_worth][bornum].include? "$"
           params[:borrower][:net_worth][bornum] = params[:borrower][:net_worth][bornum].sub('$', '')
      end

      if params[:borrower][:net_worth][bornum].include? ","
           params[:borrower][:net_worth][bornum] = params[:borrower][:net_worth][bornum].sub(',', '')
      end
      borwr.net_worth = params[:borrower][:net_worth][bornum]
      borwr.ever_borrow_money = params[:borrower][:ever_borrow_money][bornum]
      borwr.borrower_guarantor = params[:borrower][:borrower_guarantor][bornum]
      borwr.business_name = params[:borrower][:business_name][bornum]
      borwr.business_address = params[:borrower][:business_address][bornum]
      borwr.business_state = params[:borrower][:business_state][bornum]
      borwr.business_city = params[:borrower][:business_city][bornum]
      borwr.business_phone = params[:borrower][:business_phone][bornum]
      borwr.business_type = params[:borrower][:business_type][bornum]
      borwr.time_in_business = params[:borrower][:time_in_business][bornum]
      borwr.state_of_incorporation = params[:borrower][:state_of_incorporation][bornum]
      borwr.monthly_noi = params[:borrower][:monthly_noi][bornum]
      borwr.business_balance_sheet = params[:borrower][:business_balance_sheet][bornum]
      borwr.guarantor_name = params[:borrower][:guarantor_name][bornum]
      borwr.guarantor_phone = params[:borrower][:guarantor_phone][bornum]
      borwr.guarantor_email = params[:borrower][:guarantor_email][bornum]
      borwr.guarantor_address = params[:borrower][:guarantor_address][bornum]
      borwr.guarantor_state = params[:borrower][:guarantor_state][bornum]
      borwr.guarantor_city = params[:borrower][:guarantor_city][bornum]
      borwr.guarantor_postalcode = params[:borrower][:guarantor_postalcode][bornum]
      if params[:borrower][:guarantor_monthly_income][bornum].include? "$"
           params[:borrower][:guarantor_monthly_income][bornum] = params[:borrower][:guarantor_monthly_income][bornum].sub('$', '')
      end

      if params[:borrower][:guarantor_monthly_income][bornum].include? ","
           params[:borrower][:guarantor_monthly_income][bornum] = params[:borrower][:guarantor_monthly_income][bornum].sub(',', '')
      end
      borwr.guarantor_monthly_income = params[:borrower][:guarantor_monthly_income][bornum]
      borwr.guarantor_income_source = params[:borrower][:guarantor_income_source][bornum]
      borwr.guarantor_birthday = params[:borrower][:guarantor_birthday][bornum]
      borwr.guarantor_income_how_long = params[:borrower][:guarantor_income_how_long][bornum]
      borwr.guarantor_estimated_ficco = params[:borrower][:guarantor_estimated_ficco][bornum]
      borwr.guarantor_ssn = params[:borrower][:guarantor_ssn][bornum]
      borwr.guarantor_borrow_money = params[:borrower][:guarantor_borrow_money][bornum]
      if params[:borrower][:guarantor_net_worth][bornum].include? "$"
           params[:borrower][:guarantor_net_worth][bornum] = params[:borrower][:guarantor_net_worth][bornum].sub('$', '')
      end
      if params[:borrower][:guarantor_net_worth][bornum].include? ","
           params[:borrower][:guarantor_net_worth][bornum] = params[:borrower][:guarantor_net_worth][bornum].sub(',', '')
      end
      borwr.guarantor_net_worth = params[:borrower][:guarantor_net_worth][bornum]
      borwr.save

      bornum = bornum + 1
    end

    ################### End Borrower ######################

    #################### Loan Info ###################

      loan_info = params
      loan_info.delete :borrower
      loan_info.delete :collateral
      loan_info.delete :amount
      loan_info.delete :use
      loan_info.delete :is_free_related
      loan_info.delete :beneficiary
      loan_info.delete :maturityDate
      loan_info.delete :stats
      loan_info.delete :contractDate
      loan_info.delete :earnedDeposit

      dbLoan.info= loan_info
      unless params['_NetLoanAmountRequested0'].blank? 
        dbLoan.info['gross_loan_amount'] = params['_NetLoanAmountRequested0']
      end
      unless params['purchase_cash_contribute'].blank?
        dbLoan.info['acash_to_contribute'] = params['purchase_cash_contribute']
      end 
      unless params['purchase_price'].blank?
        dbLoan.info['apurchase_price'] = params['purchase_price']
      end 
      dbLoan.save

    # abort("done")
    #################### End Loan Info ###############
   
    flash[:notice] = "Application is submitted successfully"  
    redirect_to action: 'index'
 end   

 ############################ Edit Application ########################

  def edit_create_application
    
    collaterals  = params[:collateral]
    params.delete :action
    params.delete :controller  

    UseOfFund.delete_all(:loan_id => params[:loan_id].to_i)
    Collateral.delete_all(:loan_id => params[:loan_id].to_i)
    Borrower.delete_all(:loan_id => params[:loan_id].to_i)   
    
    # @last_loan = Loan.last
    # @new_id = @last_loan.id+1

    dbLoan = Loan.find_by_id(params[:loan_id].to_i)

    # abort("#{dbLoan.inspect}")
    if params[:_LoanName].blank?
      dbLoan.name = 'Awesome Loan Name'
    else
      dbLoan.name=params[:_LoanName]
    end
    unless params[:Email].blank?
      dbLoan.email = params[:Email]
    end

    
  
    
    borrowers = params[:borrower]
    borrower_types = borrowers[:borrower_type]
    bornum = 0

    bgrantr = ""
    borrower_types.each do |borrower_type|
      ############### If contact form empty ######################
       
        if params[:Email].blank?
          if bgrantr!="yes"
            if params[:borrower][:borrower_guarantor][bornum] == "Yes"
              params[:Email] = params[:borrower][:personal_email][bornum]
              params[:FirstName] = params[:borrower][:personal_name][bornum]
              params[:Phone] = params[:borrower][:personal_phone][bornum]
              dbLoan.email = params[:borrower][:personal_email][bornum]
              bgrantr="yes"
            end
          end
        end

      bornum = bornum+1
      ################ End If contact form empty #################
    end
    # abort("#{params.inspect}")
    params.each do |key, value| 
      if value.include? "$"
        if key == "_NetLoanAmountRequested0"
          params[key] = value.sub('$', '')
        elsif key == "original_purchase_price"
          params[key] = value.sub('$', '')
        elsif key == "cash_contributed"
          params[key] = value.sub('$', '')
        elsif key == "rehab_amount"   
          params[key] = value.sub('$', '') 
        end  
      end
      if value.include? ","
        if key == "_NetLoanAmountRequested0"
          params[key] = value.gsub(',', '')
        elsif key == "original_purchase_price"
          params[key] = value.gsub(',', '')
        elsif key == "cash_contributed"
          params[key] = value.gsub(',', '')
        elsif key == "rehab_amount"   
          params[key] = value.gsub(',', '') 
        end  
      end

    end

    time_nw = Time.now
    dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
    dbLoan.created_at=Time.now
    dbLoan.save

    amount = params[:amount]
    uses = params[:use]
    is_free_related = params[:is_free_related]
    beneficiary = params[:beneficiary]
    maturityDate = params[:maturityDate]
    stats = params[:stats]
    contractDate = params[:contractDate]
    earnedDeposit = params[:earnedDeposit]

    ############## Use Of Fund #####################
    
    if !uses.blank?
      num = 0

       # abort("#{dbLoan.id}")
      uses.each do |fuse|


        fundInfo = UseOfFund.new

        fundInfo.loan_id = dbLoan.id
        fundInfo.use = fuse
        unless params[:is_free_related].blank?
          fundInfo.is_free_related = is_free_related[num]
        end
        
        if amount[num].include? "$"
          amount[num] = amount[num].sub('$', '')
        end

        if amount[num].include? ","
          amount[num] = amount[num].sub(',', '')
        end
        
        fundInfo.amount = amount[num]
        fundInfo.beneficiary = beneficiary[num]
        if fuse=="Payoff"
          fundInfo.maturityDate = maturityDate[num]
          fundInfo.stats = stats[num]
        elsif fuse == "Purchase"
          fundInfo.contractDate = contractDate[num]
          if earnedDeposit[num].include? "$"
           earnedDeposit[num] = earnedDeposit[num].sub('$', '')
          end
          if earnedDeposit[num].include? ","
           earnedDeposit[num] = earnedDeposit[num].sub(',', '')
          end
          fundInfo.earnedDeposit = earnedDeposit[num]
        end
        fundInfo.save

        num = num+1
      end

    end
    ############## End Use Of Fund #####################

    #################### Collateral ################
    collaterals = params[:collateral]
    asset_types = collaterals[:asset_type]
   
    colnum = 0
    unless collaterals.blank?
      asset_types.each do |asset_type|
        colltrl = Collateral.new
        colltrl.loan_id = dbLoan.id
        colltrl.asset_type = asset_type
        colltrl.address = params[:collateral][:address][colnum]
        colltrl.city = params[:collateral][:city][colnum]
        colltrl.state = params[:collateral][:state][colnum]
        colltrl.postalcode = params[:collateral][:zipcode][colnum]
        colltrl.source_of_value = params[:collateral][:source_of_value][colnum]
        colltrl.collateral_value = params[:collateral][:collateral_value][colnum]
        if params[:collateral][:size][colnum] == "Sq Footage"
          colltrl.sq_footage = params[:collateral][:sizes_val][colnum]
        elsif params[:collateral][:size][colnum] == "Units"
          colltrl.units = params[:collateral][:sizes_val][colnum]
        elsif params[:collateral][:size][colnum] == "Acres"
          colltrl.acres = params[:collateral][:sizes_val][colnum]
        end
        colltrl.size = params[:collateral][:size][colnum]
        colltrl.property_generate_income = params[:collateral][:property_generate_income][colnum]
        if params[:collateral][:noi_ytd][colnum].include? "$"
           params[:collateral][:noi_ytd][colnum] = params[:collateral][:noi_ytd][colnum].sub('$', '')
        end
        if params[:collateral][:noi_ytd][colnum].include? ","
           params[:collateral][:noi_ytd][colnum] = params[:collateral][:noi_ytd][colnum].sub(',', '')
        end
        colltrl.noi_ytd = params[:collateral][:noi_ytd][colnum]
        if params[:collateral][:noi_last_year][colnum].include? "$"
           params[:collateral][:noi_last_year][colnum] = params[:collateral][:noi_last_year][colnum].sub('$', '')
        end
        if params[:collateral][:noi_last_year][colnum].include? ","
           params[:collateral][:noi_last_year][colnum] = params[:collateral][:noi_last_year][colnum].sub(',', '')
        end
        colltrl.noi_last_year = params[:collateral][:noi_last_year][colnum]
        if params[:collateral][:noi_two_years_ago][colnum].include? "$"
           params[:collateral][:noi_two_years_ago][colnum] = params[:collateral][:noi_two_years_ago][colnum].sub('$', '')
        end
        if params[:collateral][:noi_two_years_ago][colnum].include? ","
           params[:collateral][:noi_two_years_ago][colnum] = params[:collateral][:noi_two_years_ago][colnum].sub(',', '')
        end
        colltrl.noi_two_years_ago = params[:collateral][:noi_two_years_ago][colnum]
        colltrl.save

        colnum = colnum+1
      end
    end
    #################### End Collateral ################

    ################### Borrower ######################
    borrowers = params[:borrower]
    borrower_types = borrowers[:borrower_type]
    bornum = 0

    borrower_types.each do |borrower_type|
      ############### If contact form empty ######################
        bgrantr = ""
        if params[:Email].blank?
          if bgrantr!="yes"
            if params[:borrower][:borrower_guarantor][bornum] == "Yes"
              params[:Email] == params[:borrower][:personal_email][bornum]
              params[:FirstName] == params[:borrower][:personal_name][bornum]
              params[:Phone] == params[:borrower][:personal_phone][bornum]
            end
          end
        end

      ################ End If contact form empty #################
      borwr = Borrower.new
      borwr.loan_id = dbLoan.id
      borwr.borrower_type = borrower_type
      borwr.personal_name = params[:borrower][:personal_name][bornum]
      borwr.personal_phone = params[:borrower][:personal_phone][bornum]
      borwr.personal_email = params[:borrower][:personal_email][bornum]
      borwr.personal_address = params[:borrower][:personal_address][bornum]
      borwr.personal_state = params[:borrower][:personal_state][bornum]
      borwr.personal_city = params[:borrower][:personal_city][bornum]
      borwr.personal_postalcode = params[:borrower][:personal_postalcode][bornum]
      borwr.estimated_fico = params[:borrower][:estimated_fico][bornum]
      if params[:borrower][:net_worth][bornum].include? "$"
           params[:borrower][:net_worth][bornum] = params[:borrower][:net_worth][bornum].sub('$', '')
      end

      if params[:borrower][:net_worth][bornum].include? ","
           params[:borrower][:net_worth][bornum] = params[:borrower][:net_worth][bornum].sub(',', '')
      end
      borwr.net_worth = params[:borrower][:net_worth][bornum]
      borwr.ever_borrow_money = params[:borrower][:ever_borrow_money][bornum]
      borwr.borrower_guarantor = params[:borrower][:borrower_guarantor][bornum]
      borwr.business_name = params[:borrower][:business_name][bornum]
      borwr.business_address = params[:borrower][:business_address][bornum]
      borwr.business_state = params[:borrower][:business_state][bornum]
      borwr.business_city = params[:borrower][:business_city][bornum]
      borwr.business_phone = params[:borrower][:business_phone][bornum]
      borwr.business_type = params[:borrower][:business_type][bornum]
      borwr.time_in_business = params[:borrower][:time_in_business][bornum]
      borwr.state_of_incorporation = params[:borrower][:state_of_incorporation][bornum]
      borwr.monthly_noi = params[:borrower][:monthly_noi][bornum]
      borwr.business_balance_sheet = params[:borrower][:business_balance_sheet][bornum]
      borwr.guarantor_name = params[:borrower][:guarantor_name][bornum]
      borwr.guarantor_phone = params[:borrower][:guarantor_phone][bornum]
      borwr.guarantor_email = params[:borrower][:guarantor_email][bornum]
      borwr.guarantor_address = params[:borrower][:guarantor_address][bornum]
      borwr.guarantor_state = params[:borrower][:guarantor_state][bornum]
      borwr.guarantor_city = params[:borrower][:guarantor_city][bornum]
      borwr.guarantor_postalcode = params[:borrower][:guarantor_postalcode][bornum]
      if params[:borrower][:guarantor_monthly_income][bornum].include? "$"
           params[:borrower][:guarantor_monthly_income][bornum] = params[:borrower][:guarantor_monthly_income][bornum].sub('$', '')
      end

      if params[:borrower][:guarantor_monthly_income][bornum].include? ","
           params[:borrower][:guarantor_monthly_income][bornum] = params[:borrower][:guarantor_monthly_income][bornum].sub(',', '')
      end
      borwr.guarantor_monthly_income = params[:borrower][:guarantor_monthly_income][bornum]
      borwr.guarantor_income_source = params[:borrower][:guarantor_income_source][bornum]
      borwr.guarantor_birthday = params[:borrower][:guarantor_birthday][bornum]
      borwr.guarantor_income_how_long = params[:borrower][:guarantor_income_how_long][bornum]
      borwr.guarantor_estimated_ficco = params[:borrower][:guarantor_estimated_ficco][bornum]
      borwr.guarantor_ssn = params[:borrower][:guarantor_ssn][bornum]
      borwr.guarantor_borrow_money = params[:borrower][:guarantor_borrow_money][bornum]
      if params[:borrower][:guarantor_net_worth][bornum].include? "$"
           params[:borrower][:guarantor_net_worth][bornum] = params[:borrower][:guarantor_net_worth][bornum].sub('$', '')
      end
      if params[:borrower][:guarantor_net_worth][bornum].include? ","
           params[:borrower][:guarantor_net_worth][bornum] = params[:borrower][:guarantor_net_worth][bornum].sub(',', '')
      end
      borwr.guarantor_net_worth = params[:borrower][:guarantor_net_worth][bornum]
      borwr.save

      bornum = bornum + 1
    end

    ################### End Borrower ######################

    #################### Loan Info ###################

      loan_info = params
      loan_info.delete :borrower
      loan_info.delete :collateral
      loan_info.delete :amount
      loan_info.delete :use
      loan_info.delete :is_free_related
      loan_info.delete :beneficiary
      loan_info.delete :maturityDate
      loan_info.delete :stats
      loan_info.delete :contractDate
      loan_info.delete :earnedDeposit

      dbLoan.info= loan_info
      unless params['_NetLoanAmountRequested0'].blank? 
        dbLoan.info['gross_loan_amount'] = params['_NetLoanAmountRequested0']
      end
      unless params['purchase_cash_contribute'].blank?
        dbLoan.info['acash_to_contribute'] = params['purchase_cash_contribute']
      end 
      unless params['purchase_price'].blank?
        dbLoan.info['apurchase_price'] = params['purchase_price']
      end 
      dbLoan.save

    # abort("done")
    #################### End Loan Info ###############
   
    flash[:notice] = "Application is submitted successfully"  
    redirect_to action: 'edit_application', id:params[:loan_id]
 end 

 ############################ End Edit Applictaion ####################  
 
 def delete_loans
  ids=params[:moredata].split(",").map { |s| s.to_i }
  ids.each do |number|
      #loanRecord=Loan.find(number)
      #loanRecord.delete=1
      #loanRecord.save
      LoanUrl.delete_all(:loan_id => number)
      Document.delete_all(:loan_id => number)
      Image.delete_all(:loan_id => number)
      Nda.delete_all(:loan_id => number)
      CustomFolder.delete_all(:loan_id => number)
      Collateral.delete_all(:loan_id => number)
      Borrower.delete_all(:loan_id => number)
      UseOfFund.delete_all(:loan_id => number)
      Loan.delete(number)
  end 
  if(params[:order] == "recent")
    recent("delete")
  else
    priority("delete")
  end
  
  flash.now[:notice] = "Loans deleted successfully"
 end

 def save_loc
  id=params[:id].split(",").map { |s| s.to_i }
  loan=Loan.find_by_id(id)
  if loan.blank?
    loan=CopyLoan.find_by_id(params[:id])
  end
  loan.info["City3"] = params[:City3] 
  loan.info["State3"] = params[:State3] 
  loan.info["Address3"] = params[:Address3] 
  unless params[:_LoanName].blank?
    loan.info["_LoanName"] = params[:_LoanName]
  end
  loan.save()
  render nothing: true
  end

  def edit_info
    pdfInfo=LoanPdf.find_by_id(params[:id])
    current_sort=pdfInfo.sort_id
     if current_sort!=params[:sort_id]
      info=LoanPdf.find_by_sort_id(params[:sort_id])
      info.sort_id=current_sort
      info.save
    end
    pdfInfo.loan_name=params[:loan_name]
    pdfInfo.location=params[:location]
    pdfInfo.amount=params[:amount]
    pdfInfo.summary=params[:summary]
    pdfInfo.sort_id=params[:sort_id]
    pdfInfo.save

   
    pdfId=pdfInfo.pdf_id
    @record=Pdf.find(pdfId)
    @pdfs=@record.pdf_by_loan
    today=Time.new
    @str_time=today.strftime("%d/%m/%Y")
    render partial: 'loans/loan_listing', :locals => {:id => pdfInfo.pdf_id}
 end

 def delete_pdfs

  ids=params[:moredata].split(",")
    ids.each do |number|
      pdfInfo = Pdf.find_by_id("#{number}")
      filename = "#{pdfInfo.file_name}.pdf"
      path = 'pdfs/'+filename
      # abort("#{path}")
      File.delete(path) if File.exist?(path)
      Pdf.delete(number)
      LoanPdf.delete_all(:pdf_id => number)
    end
     @pdfs=Pdf.all(:conditions=>["name != ''"])
    render partial: 'loans/pdf_listing'
  end

 def loan_listing
  pdfId=params[:id]
   @record=Pdf.find(pdfId)
  @pdfs=@record.pdf_by_loan
  today=Time.new
  @str_time=today.strftime("%d/%m/%Y")
end

def pdforder
    @loan_ids=params[:moredata].split(",").map { |s| s }
    #abort("#{@loan_ids.inspect}")
    x=1
    @loan_ids.each do |number|
      if number!=""
        pdfInfo=LoanPdf.find(number)
        #abort("#{pdf.inspect}")
        @pdfId=pdfInfo.pdf_id
        pdfInfo.sort_id=x
        pdfInfo.save
      end
      x += 1  
    end
     @record=Pdf.find(@pdfId)
     @pdfs=@record.pdf_by_loan
     today=Time.new
     @str_time=today.strftime("%d/%m/%Y")
     render partial: 'loans/loan_listing', :locals => {:id => @pdfId}
  end

  def pdf_files
    @total = Pdf.count(:conditions=>["name != ''"])
    unless params[:per_page].blank?
      @pdfs=Pdf.paginate(:conditions=>["name != ''"], :per_page => params[:per_page], :page => params[:page], :total_entries => @total)
    else
      @pdfs=Pdf.paginate(:conditions=>["name != ''"], :per_page => 50, :page => params[:page], :total_entries => @total)
    end
    


   
    # respond_to do |format|
    # format.html # index.html.erb
    # format.json { render json: @order_requests }
    # format.js
    # end
    # abort("#{@pdfs.inspect}")
  end

  def email_pdf
     loan_url = LoanUrl.find_by_id(params[:id])
     @loan = loan_url.loan
     if loan_url
       LoanUrlMailer.email_link(loan_url).deliver
       loan_url.emailed = true
       loan_url.save
       flash.now[:notice] = "Link was sent to "+loan_url.email
     end 
         render partial: 'loans/loan_url_form'   
  end

  def generate_send
    if params[:fname]!=""
      filename=params[:fname]
    else
      filename="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
    end
    IO.write('/tmp/'+filename+'.html', params[:content])
    pdf = WickedPdf.new.pdf_from_html_file('/tmp/'+filename+'.html')
    time="loans_"+Time.now.strftime("%m-%d-%y_%H-%M-%S")
    # then save to a file
    save_path = Rails.root.join('pdfs',filename+'.pdf')
    #save_path = Rails.root.join('pdfs','loans_'+time+'.pdf')
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
     pdfInfo = Pdf.find_by_id(params[:pdfId])
     pdfInfo.file_name = filename
     unless  params[:emails].blank?
      pdfInfo.emails = params[:emails].join(", ")
     end
      pdfInfo.name=filename
      pdfInfo.content = params[:loans]
      pdfInfo.save
      
     if pdfInfo
      params[:emails].each do |email|
          LoanUrlMailer.email_pdf(pdfInfo, email).deliver
      end
       pdfInfo.status = 1
       pdfInfo.save
     end 
     pdf_filename =  filename+".pdf"
     send_data(pdf_filename, :filename => "your_document.pdf", :type => "application/pdf")
     #redirect_to :action => "pdf_files", :id => "listing"
  end

  def custom_search_pdf
       @pdfs=Pdf.all(:conditions=>["name != ''"])

       @match_ids = Array.new
       @searchtxt = params[:search_txt].downcase
       
       @pdfs.each do |pdf|
            
            unless pdf.file_name.blank?
              file_name = pdf.file_name.downcase
              if file_name.include? "#{@searchtxt}"
                @match_ids << pdf.id
              end
            end

            unless pdf.emails.blank?
              pemail = pdf.emails.downcase
              if pemail.include? "#{@searchtxt}"
                @match_ids << pdf.id
              end
            end

            # abort("#{@match_ids}")
            @loans = pdf.pdf_by_loan
            @loans.each do |loan|

                unless loan.loan_name.blank?
                  loan_name = loan.loan_name.downcase
                  if loan_name.include? "#{@searchtxt}"
                    @match_ids << pdf.id
                  end
                end
                
                unless loan.location.blank?
                  location = loan.location.downcase
                  if location.include? "#{@searchtxt}"
                    @match_ids << pdf.id
                  end
                end

                unless loan.summary.blank?
                  summary = loan.summary.downcase
                  if summary.include? "#{@searchtxt}"
                    @match_ids << pdf.id
                  end
                end
                

                unless loan.amount.blank?
                  amount = loan.amount
                  if amount.include? "#{@searchtxt}"
                    @match_ids << pdf.id
                  end
                end

            end
       end

       @match_ids = @match_ids.uniq
       
       @pdfs = Pdf.find(@match_ids)
       render partial: 'loans/pdf_listing'
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
    if @checkAdmin==true
      all_loans=Loan.all
    else
      broker_loans = Array.new
      broker = Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          subbroker = Broker.find(req.subbroker_id)
          unless subbroker.blank?
              b_loans = Loan.where(:email => subbroker.email).fields(:id).all
              b_loans.each do |loan_id|
                  broker_loans << loan_id.id
              end
          end
        end
        br_loans = Loan.where(:email => broker.email).fields(:id).all
        br_loans.each do |bloan_id|
            broker_loans << bloan_id.id
        end
      end
      all_loans=Loan.all(:id => broker_loans)
    end
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
   # @search = "yes"

   
   if params['sorting'] == "recent"
      
      if ids.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans = Loan.paginate(:id=>ids, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
        # @loans = Loan.all(:id=>ids, :order => :id.desc)
        
        @total_loans = Loan.count(:id=>ids, :delete.ne => 1, :archived.ne => true);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
        else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
        end



      end


      flash.now[:notice] = "Searching by recent Loans"
      render partial: 'loans/all_loans'
   elsif params['sorting'] == "incomplete_loan"
      
  ################ Incomplete Loan ###################

    if ids.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans = Loan.paginate(:id=>ids, :incomplete=>1, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
        # @loans = Loan.all(:id=>ids, :order => :id.desc)
        
        @total_loans = Loan.count(:id=>ids, :incomplete=>1, :delete.ne => 1, :archived.ne => true);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
        else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
        end



      end


      flash.now[:notice] = "Searching by Incomplete Loans"
      render partial: 'loans/all_loans'



  ################ Incomplete Loan ###################

   else
      if ids.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans = Loan.paginate(:id=>ids, :delete.ne => 1, :archived.ne => true, :on_priority=>1, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :priority_num.asc)
        # @loans = Loan.all(:id=>ids, :on_priority=>1, :order => :priority_num.desc)
        @total_loans = Loan.count(:id=>ids, :delete.ne => 1, :archived.ne => true, :on_priority=>1);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
        else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
        end

      end
      flash.now[:notice] = "Searching by priority"
      render partial: 'loans/sort_loans'
   end
   ########################################### Check Sorting End ##############################################
  end

  def post_new_loan
    # abort("#{params}")
    unless params.blank?
      params.delete :action
      params.delete :_wp_http_referer
      params.delete :controller
      @last_loan = Loan.last
      @new_id = @last_loan.id+1
      time = Time.new
     unless  params[:nvid].blank?
         id = params[:nvid].to_i
        dbloan=Loan.find_by_id(id)
        newloan="no"
      else
        dbloan=Loan.new
        newloan="yes"
      end

      params.each do |key, value| 
          if value == "0000-00-00"
            params[key] = ""
          end
      end
      # abort("#{params.inspect}")
      if params[:contract_closing_date]=="0000-00-00"
        params[:contract_closing_date] = ""
      end

      if params[:maturity_date]=="0000-00-00"
        params[:maturity_date] = ""
      end

       if params[:contract_closing_date]=="0000-00-00"
        params[:contract_closing_date] = ""
      end

      unless params[:_LendingCategory].blank?

        if params[:_LendingCategory] == "private_loan"
          params[:_LendingCategory] = "Private Real Estate Loan"
        elsif params[:_LendingCategory]== "business_loan"
          params[:_LendingCategory] = "Business Financing"
        elsif params[:_LendingCategory]== "equity_loan"
          params[:_LendingCategory] = "Equity and Crowdfunding"
        elsif params[:_LendingCategory]== "residential_loan"
          params[:_LendingCategory] = "Residential or Commercial Mortgage"
        end 

      end

      if  params[:stepping] == "1"
       if params[:contractDate] == "-"
          params[:contractDate] = ""
       end
       if params[:maturityDate] == "-"
          params[:maturityDate] = ""
       end
       if params[:contract_closing_date] == "|"
        params[:contract_closing_date] = ""
       end
        UseOfFund.delete_all(:loan_id => params[:nvid].to_i)
        unless params[:use].blank?
            uses = params[:use].split("|")
            amounts = params[:amount].split("|")
            beneficiary = params[:beneficiary].split("|")
            maturityDate = params[:maturityDate].split("|")
            stats = params[:stats].split("|")
            contractDate = params[:contractDate].split("|")
            earnedDeposit = params[:earnedDeposit].split("|")
            payid = params[:payid].split("|")
            unless params[:is_free_related].blank?
              isfreerelated = params[:is_free_related].split("|") 
            end

            fund_num = 0
            uses.each do |fuse|
              fundInfo = UseOfFund.new
              fundInfo.loan_id = params[:nvid]
              fundInfo.use = fuse
              unless params[:is_free_related].blank?
                fundInfo.is_free_related = isfreerelated[fund_num]
              end
              fundInfo.amount = amounts[fund_num]
              fundInfo.beneficiary = beneficiary[fund_num]
              fundInfo.payid = payid[fund_num]
              if fuse=="Payoff"
                fundInfo.maturityDate = maturityDate[fund_num]
                fundInfo.stats = stats[fund_num]
              elsif fuse == "Purchase"
                fundInfo.contractDate = contractDate[fund_num]
                fundInfo.earnedDeposit = earnedDeposit[fund_num]
              end
              fundInfo.save

              fund_num = fund_num+1
            end
        end 

         
      end
      
    if params[:stepping] == "2"
        Collateral.delete_all(:loan_id => params[:nvid].to_i)


        unless params[:address].blank?
          cnum = 0
          addresses = params[:address].split("|")
          city = params[:city].split("|")
          state = params[:state].split("|")
          zipcode = params[:zipcode].split("|")
          source_of_value = params[:source_of_value].split("|")
          date_last_valuation = params[:date_last_valuation].split("|")
          date_last_bpo = params[:date_last_bpo].split("|")
          property_generate_income = params[:property_generate_income].split("|")
          noi_ytd = params[:noi_ytd].split("|")
          noi_two_years_ago = params[:noi_two_years_ago].split("|")
          noi_last_year = params[:noi_last_year].split("|")
          size = params[:size].split("|")
          sq_footage = params[:sq_footage].split("|")
          sq_footage = params[:sq_footage].split("|")
          acres = params[:acres].split("|")
          units = params[:units].split("|")
          asset_type = params[:asset_type].split("|")
          collateralval = params[:collateral_value].split("|")
          related_payoffs = params[:related_payoffs].split("|")
          structural_size = params[:structural_size].split("|")
          structural_sq_footage = params[:structural_sq_footage].split("|")
          sf_per_unit = params[:sf_per_unit].split("|")

         
          # maturity_date = params[:maturity_date].split("|")
          # refinance_cash_contribute = params[:refinance_cash_contribute].split("|")
          # original_purchase_price = params[:original_purchase_price].split("|")
          # vested_by = params[:vested_by].split("|")
          # original_purchase_date = params[:original_purchase_date].split("|")
          # cash_contributed = params[:cash_contributed].split("|")
          # cash_contributed = params[:cash_contributed].split("|")

          addresses.each do |adrs|
            collateral =  Collateral.new
            if adrs!="-"
              collateral.address = adrs;
            end
            if sq_footage[cnum]!="-"
              collateral.sq_footage = sq_footage[cnum];
            end
            if units[cnum]!="-"
              collateral.units = units[cnum];
            end
            if acres[cnum]!="-"
              collateral.acres = acres[cnum];
            end
            if asset_type[cnum]!="-"
              collateral.asset_type = asset_type[cnum];
            end
            if city[cnum]!="-"
              collateral.city = city[cnum];
            end
            if state[cnum]!="-"
              collateral.state = state[cnum];
            end
            if zipcode[cnum]!="-"
              collateral.postalcode = zipcode[cnum];
            end
            if structural_size[cnum]!="-"
              collateral.structural_size = structural_size[cnum];
            end
            if structural_sq_footage[cnum]!="-"
              collateral.structural_sq_footage = structural_sq_footage[cnum];
            end
            if sf_per_unit[cnum]!="-"
              collateral.sf_per_unit = sf_per_unit[cnum];
            end
            if related_payoffs[cnum]!="-"
              collateral.related_payoffs = related_payoffs[cnum];
              poffs = related_payoffs[cnum].split(',')
              relat = Array.new
              poffs.each do |poff|
                
                pInfo = UseOfFund.find_by_payid(poff.to_i)

                unless pInfo.blank?
                  relat << pInfo.id
                end
              
              end
              # abort("#{relat}")
              related = relat.join(",")
              
              collateral.related_funds = related
            end

            if collateralval[cnum]!="-"
              collateral.collateral_value = collateralval[cnum];
            end

            if source_of_value[cnum]!="-"
              collateral.source_of_value = source_of_value[cnum];
            end
            if source_of_value[cnum]=="Appraisal"
              if date_last_valuation[cnum]!="-"
                collateral.date_last_valuation = date_last_valuation[cnum]
              end
            end
            if source_of_value[cnum]=="BPO/CMA"
              if date_last_bpo[cnum]!="-"
                collateral.date_last_bpo = date_last_bpo[cnum]
              end
            end
            if property_generate_income[cnum]!="-"
              collateral.property_generate_income = property_generate_income[cnum]
            end
            if property_generate_income[cnum]=="Yes"
              if noi_ytd[cnum]!="-"
                collateral.noi_ytd = noi_ytd[cnum]
              end
              if noi_two_years_ago[cnum]!="-"
               collateral.noi_two_years_ago = noi_two_years_ago[cnum]
              end
              if noi_last_year[cnum]!="-"
                collateral.noi_last_year = noi_last_year[cnum]
              end
            end
            if size[cnum]!="-"
              collateral.size = size[cnum]
            end
            collateral.loan_id = params[:nvid].to_i
            collateral.save
           
            cnum = cnum + 1
          end
            
            
        end
    end
     

      if params[:stepping] == "3"
        Borrower.delete_all(:loan_id => params[:nvid].to_i)
        all_fields = Hash.new
        params.each do |key, value| 
          all_fields["#{key}"] = value.split("|")
        end

       
        b = 0
        all_fields['borrower_type'].each do |type|
          borow = Borrower.new
          
          if type!="-"
            borow.borrower_type = type
          end

           if all_fields['personal_name'][b]!="-"
            borow.personal_name = all_fields['personal_name'][b]
          end

          if all_fields['personal_phone'][b]!="-"
            borow.personal_phone = all_fields['personal_phone'][b]
          end

          if all_fields['personal_email'][b]!="-"
            borow.personal_email = all_fields['personal_email'][b]
          end

           if all_fields['personal_dob'][b]!="-"
            borow.personal_dob = all_fields['personal_dob'][b]
            # abort("In #{borow.personal_dob}")
          end

          # abort("Out #{all_fields['personal_dob'][b]}")

          if all_fields['personal_address'][b]!="-"
            borow.personal_address = all_fields['personal_address'][b]
          end
          if all_fields['personal_city'][b]!="-"
            borow.personal_city = all_fields['personal_city'][b]
          end
          if all_fields['personal_postalcode'][b]!="-"
            borow.personal_postalcode = all_fields['personal_postalcode'][b]
          end
          if all_fields['personal_monthly_income'][b]!="-"
            borow.personal_monthly_income = all_fields['personal_monthly_income'][b]
          end
          if all_fields['personal_income_source'][b]!="-"
            borow.personal_income_source = all_fields['personal_income_source'][b]
          end
          if all_fields['income_how_long'][b]!="-"
            borow.income_how_long = all_fields['income_how_long'][b]
          end
          if all_fields['personal_ssn'][b]!="-"
            borow.personal_ssn = all_fields['personal_ssn'][b]
          end
          if all_fields['net_worth'][b]!="-"
            borow.net_worth = all_fields['net_worth'][b]
          end
          if all_fields['personal_state'][b]!="-"
            borow.personal_state = all_fields['personal_state'][b]
          end
         
          if all_fields['estimated_fico'][b]!="-"
            borow.estimated_fico = all_fields['estimated_fico'][b]
          end
          if all_fields['ever_borrow_money'][b]!="-"
            borow.ever_borrow_money = all_fields['ever_borrow_money'][b]
          end
          if all_fields['borrower_guarantor'][b]!="-"
            borow.borrower_guarantor = all_fields['borrower_guarantor'][b]
          end
          if all_fields['business_name'][b]!="-"
            borow.business_name = all_fields['business_name'][b]
          end
          if all_fields['business_address'][b]!="-"
            borow.business_address = all_fields['business_address'][b]
          end
          if all_fields['business_state'][b]!="-"
            borow.business_state = all_fields['business_state'][b]
          end
          if all_fields['business_phone'][b]!="-"
            borow.business_phone = all_fields['business_phone'][b]
          end
           if all_fields['business_city'][b]!="-"
            borow.business_city = all_fields['business_city'][b]
          end
          if all_fields['time_in_business'][b]!="-"
            borow.time_in_business = all_fields['time_in_business'][b]
          end
          if all_fields['monthly_noi'][b]!="-"
            borow.monthly_noi = all_fields['monthly_noi'][b]
          end
           if all_fields['business_balance_sheet'][b]!="-"
            borow.business_balance_sheet = all_fields['business_balance_sheet'][b]
          end
          if all_fields['guarantor_name'][b]!="-"
            borow.guarantor_name = all_fields['guarantor_name'][b]
          end
           if all_fields['guarantor_phone'][b]!="-"
            borow.guarantor_phone = all_fields['guarantor_phone'][b]
          end
          if all_fields['guarantor_email'][b]!="-"
            borow.guarantor_email = all_fields['guarantor_email'][b]
          end
           if all_fields['guarantor_address'][b]!="-"
            borow.guarantor_address = all_fields['guarantor_address'][b]
          end

          if all_fields['guarantor_city'][b]!="-"
            borow.guarantor_city = all_fields['guarantor_city'][b]
          end 

          if all_fields['guarantor_monthly_income'][b]!="-"
            borow.guarantor_monthly_income = all_fields['guarantor_monthly_income'][b]
          end
          

          if all_fields['guarantor_state'][b]!="-"
            borow.guarantor_state = all_fields['guarantor_state'][b]
          end
           if all_fields['guarantor_postalcode'][b]!="-"
            borow.guarantor_postalcode = all_fields['guarantor_postalcode'][b]
          end
          if all_fields['guarantor_income_source'][b]!="-"
            borow.guarantor_income_source = all_fields['guarantor_income_source'][b]
          end
          if all_fields['guarantor_income_how_long'][b]!="-"
            borow.guarantor_income_how_long = all_fields['guarantor_income_how_long'][b]
          end
          if all_fields['guarantor_estimated_ficco'][b]!="-"
            borow.guarantor_estimated_ficco = all_fields['guarantor_estimated_ficco'][b]
          end
          if all_fields['guarantor_net_worth'][b]!="-"
            borow.guarantor_net_worth = all_fields['guarantor_net_worth'][b]
          end
          if all_fields['guarantor_borrow_money'][b]!="-"
            borow.guarantor_borrow_money = all_fields['guarantor_borrow_money'][b]
          end
          if all_fields['guarantor_ssn'][b]!="-"
            borow.guarantor_ssn = all_fields['guarantor_ssn'][b]
          end
          if all_fields['guarantor_birthday'][b]!="-"
            borow.guarantor_birthday = all_fields['guarantor_birthday'][b]
          end
          if all_fields['state_of_incorporation'][b]!="-"
            borow.state_of_incorporation = all_fields['state_of_incorporation'][b]
          end
          if all_fields['business_type'][b]!="-"
            borow.business_type = all_fields['business_type'][b]
          end
          borow.loan_id = params[:nvid].to_i
          # abort("#{borow.inspect}")
          borow.save
         
          b = b+1
        end
     

        
      end

      if params[:nvid].blank?
        dbloan.info= params
        dbloan.email = params[:Email]
        dbloan.fd_id = params[:fd_id].to_i
        dbloan.created_date = time.strftime("%Y-%m-%d %H:%M:%S")
        dbloan.created_at=Time.now
        dbloan.id = @new_id
        dbloan.incomplete = 1
        dbloan.created_by_info = "Funding"
        dbloan.created_by_email = params[:Email]
        dbloan.created_by_name = params[:FirstName]
      else
        if params[:stepping] == "1" 
          @info_arr = dbloan.info
          @innfo_arr=@info_arr.merge(params)

          dbloan.info = @innfo_arr
          dbloan.info['gross_loan_amount'] = params['_NetLoanAmountRequested0']
          unless params['purchase_cash_contribute'].blank?
            dbloan.info['acash_to_contribute'] = params['purchase_cash_contribute']
          end 
          unless params['purchase_price'].blank?
            dbloan.info['apurchase_price'] = params['purchase_price']
          end 

        end
      end

      unless params[:_LoanName].blank?
        dbloan.name= params[:_LoanName]
      end
      if params[:stepping]
        dbloan.stepping = params[:stepping]
      end

      if params[:stepping] == "3" 
        dbloan.completed = 1
        dbloan.incomplete = 0
      end
      dbloan.updated_at = Time.now
      dbloan.save

      unless  params[:Email].blank?
         enc = Base64.encode64(dbloan.id.to_s)
         enc2 = Base64.encode64(enc)
         dbloan.doc_url = enc2
         dbloan.url_time = Time.now.getutc
         dbloan.save
      end
      if params[:stepping] == "3"
           LoanUrlMailer.thankyou_fdLoan(dbloan.id).deliver
           LoanUrlMailer.complete_loan(params[:nvid]).deliver
         end
      if  params[:stepping] == "18"
        # LoanUrlMailer.complete_loan(params[:nvid]).deliver
      end
     end
     render json: dbloan
  end


  def incomplete_loans
    ids=params[:id].split(",")
    ids.each do |id|
      num = id.to_i
      LoanUrlMailer.incomplete_loan(num).deliver
    end
    render json: "OK"
  end
  
  def add_folder
    folder = CustomFolder.new
    folder.folder_name = params[:folder_name]
    folder.loan_id = params[:loan_id]
    unless params[:user_id].blank?
      folder.user_id = params[:user_id]
    end
    folder.saved
    @loan_id =  params[:loan_id]
    @folders = CustomFolder.all(:loan_id => params[:loan_id].to_i, :delete.ne=>1, :hide.ne=>1)
    render partial: 'loans/all_folders'
  end

  def edit_add_folder
    folder = CustomFolder.new
    folder.folder_name = params[:folder_name]
    folder.loan_id = params[:loan_id]
    unless params[:user_id].blank?
      folder.user_id = params[:user_id]
    end
    folder.save
    @loan_id =  params[:loan_id]
    @folders = CustomFolder.all(:loan_id => params[:loan_id].to_i, :delete.ne=>1, :hide.ne=>1)
    render partial: 'loans/edit_all_folders'
  end

  def verify_custom_authenticity_token
  # checks whether the request comes from a trusted source
  end

  def detail
     #id = Base64.decode64(Base64.decode64(params[:id]))
    loan_url = LoanUrl.find_by_url(params[:id])
    @loan = Loan.find(params[:id].to_i)
    if !loan_url.blank?
        loan_detail = loan_url.loan
        uInfo = User.find_by_email(loan_detail.email)
        #abort("#{uInfo.inspect}")
        if !uInfo.blank?
          if defined? uInfo.plan
            if uInfo.plan == "SOLO"
             total_visits = loan_url.visits.count
             if(total_visits == 5 || total_visits > 5 )
                #abort("#{total_visits}")
                  flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
                  redirect_to '/'
                
              end   
            end
          end
        end
        if loan_url.visits.blank?
          loan_url.visits = Array.new
        end
        loan_url.visits<<Time.now.getutc
        loan_url.save
        @loan = Loan.find_by_id(loan_url.loan_id)
        # @info = @loan
        
       ############## Bar Chart ###################

        @funds = UseOfFund.all(:loan_id => @loan.id)
    
        unless @funds.blank?
            @uses = Array.new
            @amounts = Array.new
            @uses<<""
            @amounts<<""
            @funds.each do |fund|
              if fund.use.blank?
                @uses<< ""
              else
                @uses<< fund.use
              end

              if fund.amount.blank?
                @amounts << "0"
              else
                @amounts<< fund.amount
              end
              
            end
        end


       ############## End Bar Chart ###############

       @borrowers = Borrower.all(:loan_id => @loan.id, :hide.ne=>1)
       @collaterals = Collateral.all(:loan_id => @loan.id, :hide.ne=>1)
       # @access = "true"
       @login = "true"
    elsif !@loan.blank?
       @login = "true"
       ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
       @ultv = ltv *100
       @lltv = @ultv.round(2)
       ############## Bar Chart ###################

        @funds = UseOfFund.all(:loan_id => @loan.id)
    
        unless @funds.blank?
            @uses = Array.new
            @amounts = Array.new
            @uses<<""
            @amounts<<""
            @funds.each do |fund|
              if fund.use.blank?
                @uses<< ""
              else
                @uses<< fund.use
              end

              if fund.amount.blank?
                @amounts << "0"
              else
                @amounts<< fund.amount
              end
              
            end
        end


       ############## End Bar Chart ###############
       @borrowers = Borrower.all(:loan_id => @loan.id, :hide.ne=>1)
       @collaterals = Collateral.all(:loan_id => @loan.id, :hide.ne=>1)
       # abort("#{@borrowers.inspect}")
    else
      flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
      redirect_to '/'
    end
    
  
  end

  def detail_loan
     #id = Base64.decode64(Base64.decode64(params[:id]))
    if params[:login] == "info" || params[:login] == "required"
      @valid = "yes"
    end 
    loan_url = LoanUrl.find_by_url(params[:id])
    @loan = Loan.find(params[:id].to_i)
    if !@loan.blank? && @valid == "yes"
       ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
       @ultv = ltv *100
       @lltv = @ultv.round(2)
       @funds = UseOfFund.all(:loan_id => @loan.id)
       if params[:login] == "info"
        @login = "true"
       end

       if !current_user.blank?
          @login = "true"
       end
    else
      flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
      redirect_to '/'
    end
    
  
  end

  def manual_shop_loan
    ids = params[:moredata].split(",")
    
    ids.each do |id|
      detail = Loan.find(id.to_i)
      copyLoan = CopyLoan.new
      copyLoan.name = detail.name 
      copyLoan.info = detail.info
      
      if !detail.email.blank?
        copyLoan.email = detail.email
      elsif defined? detail.info['Email']
        copyLoan.email = detail.info['Email']
      end
      
      if !detail.added_by.blank?
        copyLoan.added_by = detail.added_by
      end
      if @brokerLogin==true  
        copyLoan.broker_id = @infoBroker.id
      end
      copyLoan.hide_fields = detail.hide_fields
      copyLoan.user_id = @infoUser.id
      copyLoan.loan_id = detail.id
      copyLoan.shop_date = Time.now.getutc
      copyLoan.phase = "screening"
      copyLoan.save

      funds = detail.use_of_fund
      funds.each do |fund|
        fnd = UseFund.new
        fnd.fund_id = fund.id
        fnd.use = fund.use
        fnd.amount = fund.amount
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.beneficiary = fund.beneficiary
        fnd.maturityDate = fund.maturityDate
        fnd.stats = fund.stats
        fnd.contractDate = fund.contractDate
        fnd.earnedDeposit = fund.earnedDeposit
        fnd.is_free_related = fund.is_free_related
        fnd.save
      end

      pays = detail.pay_offs
      pays.each do |pay|
        fnd = PayOff.new
        fnd.amount = pay.amount
        fnd.recipient = pay.recipient
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.save
      end

      borrowers = detail.borrower

      borrowers.each do |borrower|
        brwr = CopyBorrower.new
        brwr.copy_loan_id = "#{copyLoan.id}"
        brwr.personal_name = borrower.personal_name
        brwr.personal_phone = borrower.personal_phone
        brwr.personal_email = borrower.personal_email
        brwr.personal_address = borrower.personal_address
        brwr.personal_city = borrower.personal_city
        brwr.personal_state = borrower.personal_state
        brwr.personal_postalcode = borrower.personal_postalcode
        brwr.personal_dob = borrower.personal_dob
        brwr.personal_ein = borrower.personal_ein
        brwr.personal_ssn = borrower.personal_ssn
        brwr.personal_gross = borrower.personal_gross
        brwr.personal_cashContribution = borrower.personal_cashContribution
        brwr.personal_monthly_income = borrower.personal_monthly_income
        brwr.personal_income_source = borrower.personal_income_source
        brwr.income_how_long = borrower.income_how_long
        brwr.estimated_fico = borrower.estimated_fico
        brwr.net_worth = borrower.net_worth
        brwr.ever_borrow_money = borrower.ever_borrow_money
        brwr.bio = borrower.bio
        brwr.business_name = borrower.business_name
        brwr.business_phone = borrower.business_phone
        brwr.business_address = borrower.business_address
        brwr.business_city = borrower.business_city
        brwr.business_state = borrower.business_state
        brwr.business_postalcode = borrower.business_postalcode
        brwr.business_type = borrower.business_type
        brwr.business_balance_sheet = borrower.business_balance_sheet
        brwr.state_of_incorporation = borrower.state_of_incorporation
        brwr.time_in_business = borrower.time_in_business
        brwr.revenue_time_period = borrower.revenue_time_period
        brwr.business_ein = borrower.business_ein
        brwr.cash_on_hand = borrower.cash_on_hand
        brwr.est_fico = borrower.est_fico
        brwr.available_credit = borrower.available_credit
        brwr.monthly_noi =  borrower.monthly_noi
        brwr.annual_noi = borrower.annual_noi
        brwr.account_recievable = borrower.account_recievable
        brwr.account_payable = borrower.account_payable
        brwr.borrower_type = borrower.borrower_type
        brwr.balance_sheet = borrower.balance_sheet
        brwr.guarantor_name = borrower.guarantor_name
        brwr.guarantor_phone = borrower.guarantor_phone
        brwr.guarantor_email = borrower.guarantor_email
        brwr.guarantor_address = borrower.guarantor_address
        brwr.guarantor_city = borrower.guarantor_city
        brwr.guarantor_state = borrower.guarantor_state
        brwr.guarantor_postalcode = borrower.guarantor_postalcode
        brwr.guarantor_monthly_income = borrower.guarantor_monthly_income
        brwr.guarantor_income_source = borrower.guarantor_income_source
        brwr.guarantor_income_how_long = borrower.guarantor_income_how_long
        brwr.guarantor_birthday = borrower.guarantor_birthday
        brwr.guarantor_ssn = borrower.guarantor_ssn
        brwr.guarantor_estimated_ficco = borrower.guarantor_estimated_ficco
        brwr.guarantor_net_worth = borrower.guarantor_net_worth
        brwr.guarantor_borrow_money = borrower.guarantor_borrow_money
        brwr.borrower_guarantor = borrower.borrower_guarantor
        brwr.hide_fields = brwr.hide_fields
        brwr.save
      end

      collaterals = detail.collateral
      collaterals.each do |collateral|
        coltrl = CopyCollateral.new
        coltrl.copy_loan_id = "#{copyLoan.id}"
        coltrl.address = collateral.address
        coltrl.city = collateral.city
        coltrl.state = collateral.state
        coltrl.postalcode = collateral.postalcode
        coltrl.estimated_value = collateral.estimated_value
        coltrl.amount_owed = collateral.amount_owed
        coltrl.mortgage_status = collateral.mortgage_status
        coltrl.gross_monthly_income = collateral.gross_monthly_income
        coltrl.purchase_price = collateral.purchase_price
        coltrl.original_purchase_price = collateral.original_purchase_price
        coltrl.source_of_value = collateral.source_of_value
        coltrl.date_last_valuation = collateral.date_last_valuation
        coltrl.date_last_bpo = collateral.date_last_bpo
        coltrl.property_generate_income = collateral.property_generate_income
        coltrl.noi_ytd = collateral.noi_ytd
        coltrl.noi_last_year = collateral.noi_last_year
        coltrl.noi_two_years_ago = collateral.noi_two_years_ago
        coltrl.noi_this_year = collateral.noi_this_year
        coltrl.noi_two_years_from_now = collateral.noi_two_years_from_now
        coltrl.transaction_type = collateral.transaction_type
        coltrl.signed_contract = collateral.signed_contract
        coltrl.contract_closing_date = collateral.contract_closing_date
        coltrl.rehab_amount = collateral.rehab_amount
        coltrl.purchase_cash_contribute = collateral.purchase_cash_contribute
        coltrl.maturity_date = collateral.maturity_date
        coltrl.refinance_cash_contribute = collateral.refinance_cash_contribute
        coltrl.vested_by = collateral.vested_by
        coltrl.original_purchase_date = collateral.original_purchase_date
        coltrl.cash_contributed = collateral.cash_contributed
        coltrl.asset_type = collateral.asset_type
        coltrl.hide_fields = coltrl.hide_fields
        coltrl.size = coltrl.size
        coltrl.sq_footage = coltrl.sq_footage
        coltrl.acres = coltrl.acres
        coltrl.structural_size = coltrl.structural_size
        coltrl.structural_sq_footage = coltrl.structural_sq_footage
        coltrl.units = coltrl.units
        coltrl.sf_per_unit = coltrl.sf_per_unit

        unless collateral.related_funds.blank?
          fnds = UseFund.all(:copy_loan_id => "#{copyLoan.id}")
          unless fnds.blank?
            # abort("#{collateral.related_funds}")
            relate = Array.new
            fnds.each do |fnd|
              if collateral.related_funds.include? fnd.fund_id
                relate << fnd.id
              end 
            end
            related_funds = relate.join(',')
            coltrl.related_funds = related_funds
          end
        end
        
        coltrl.save

      end


      shop = ShopLoan.new
      shop.loan_id = detail.id
      if @brokerLogin==true 
         shop.broker_id = @infoBroker.id
      end
      shop.user_id = @infoUser.id
      shop.copy_loan_id = copyLoan.id
      shop.shop_date = Time.now.getutc
      shop.save

      allrms = [12, 5, 1, 30]
      # abort("#{allrms.inspect}")

      allrms.each do |rm|
        check = Reminder.all(:num => rm, :copy_loan_id => copyLoan.id.to_s)
        if check.blank?
          reminder = Reminder.new
          reminder.num = rm
          if rm == 30
            reminder.units = "min"
          else
            reminder.units = "hours"
          end
          reminder.status =  0
          reminder.copy_loan_id = copyLoan.id.to_s
          reminder.save
        end
      end 

        LoanUrlMailer.shop_loan(copyLoan.id).deliver
    end
      if(params[:sorting] == "recent")
        recent("shop_loan")
      else
        priority("shop_loan")
      end
      #render text: "Done"
  
  end

  def single_shop_loan
    id = params[:id]
    
      detail = Loan.find(id.to_i)
      copyLoan = CopyLoan.new
      copyLoan.name = detail.name 
      copyLoan.info = detail.info
      
      if !detail.email.blank?
        copyLoan.email = detail.email
      elsif defined? detail.info['Email']
        copyLoan.email = detail.info['Email']
      end
      
      if !detail.added_by.blank?
        copyLoan.added_by = detail.added_by
      end
      if @brokerLogin==true  
        copyLoan.broker_id = @infoBroker.id
      end
      copyLoan.user_id = @infoUser.id
      copyLoan.hide_fields = detail.hide_fields
      copyLoan.loan_id = detail.id
      copyLoan.shop_date = Time.now.getutc
      copyLoan.phase = "screening"
      #copyLoan.featured = detail.id
      copyLoan.save

      funds = detail.use_of_fund
      funds.each do |fund|
        fnd = UseFund.new
        fnd.fund_id = fund.id
        fnd.use = fund.use
        fnd.amount = fund.amount
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.beneficiary = fund.beneficiary
        fnd.maturityDate = fund.maturityDate
        fnd.stats = fund.stats
        fnd.contractDate = fund.contractDate
        fnd.earnedDeposit = fund.earnedDeposit
        fnd.is_free_related = fund.is_free_related
        fnd.save
        
      end

      # pays = detail.pay_offs
      # pays.each do |pay|
      #   fnd = PayOff.new
      #   fnd.fund_id = fund.id
      #   fnd.use = fund.use
      #   fnd.amount = fund.amount
      #   fnd.copy_loan_id = "#{copyLoan.id}"
      #   fnd.beneficiary = fund.beneficiary
      #   fnd.maturityDate = fund.maturityDate
      #   fnd.stats = fund.stats
      #   fnd.contractDate = fund.contractDate
      #   fnd.earnedDeposit = fund.earnedDeposit
      #   fnd.is_free_related = fund.is_free_related
      #   fnd.save
      # end
      
      borrowers = detail.borrower
      borrowers.each do |borrower|
        brwr = CopyBorrower.new
        brwr.copy_loan_id = "#{copyLoan.id}"
        brwr.personal_name = borrower.personal_name
        brwr.personal_phone = borrower.personal_phone
        brwr.personal_email = borrower.personal_email
        brwr.personal_address = borrower.personal_address
        brwr.personal_city = borrower.personal_city
        brwr.personal_state = borrower.personal_state
        brwr.personal_postalcode = borrower.personal_postalcode
        brwr.personal_dob = borrower.personal_dob
        brwr.personal_ein = borrower.personal_ein
        brwr.personal_ssn = borrower.personal_ssn
        brwr.personal_gross = borrower.personal_gross
        brwr.personal_cashContribution = borrower.personal_cashContribution
        brwr.personal_monthly_income = borrower.personal_monthly_income
        brwr.personal_income_source = borrower.personal_income_source
        brwr.income_how_long = borrower.income_how_long
        brwr.estimated_fico = borrower.estimated_fico
        brwr.net_worth = borrower.net_worth
        brwr.ever_borrow_money = borrower.ever_borrow_money
        brwr.bio = borrower.bio
        brwr.business_name = borrower.business_name
        brwr.business_phone = borrower.business_phone
        brwr.business_address = borrower.business_address
        brwr.business_city = borrower.business_city
        brwr.business_state = borrower.business_state
        brwr.business_postalcode = borrower.business_postalcode
        brwr.business_type = borrower.business_type
        brwr.business_balance_sheet = borrower.business_balance_sheet
        brwr.state_of_incorporation = borrower.state_of_incorporation
        brwr.time_in_business = borrower.time_in_business
        brwr.revenue_time_period = borrower.revenue_time_period
        brwr.business_ein = borrower.business_ein
        brwr.cash_on_hand = borrower.cash_on_hand
        brwr.est_fico = borrower.est_fico
        brwr.available_credit = borrower.available_credit
        brwr.monthly_noi =  borrower.monthly_noi
        brwr.annual_noi = borrower.annual_noi
        brwr.account_recievable = borrower.account_recievable
        brwr.account_payable = borrower.account_payable
        brwr.borrower_type = borrower.borrower_type
        brwr.balance_sheet = borrower.balance_sheet
        brwr.guarantor_name = borrower.guarantor_name
        brwr.guarantor_phone = borrower.guarantor_phone
        brwr.guarantor_email = borrower.guarantor_email
        brwr.guarantor_address = borrower.guarantor_address
        brwr.guarantor_city = borrower.guarantor_city
        brwr.guarantor_state = borrower.guarantor_state
        brwr.guarantor_postalcode = borrower.guarantor_postalcode
        brwr.guarantor_monthly_income = borrower.guarantor_monthly_income
        brwr.guarantor_income_source = borrower.guarantor_income_source
        brwr.guarantor_income_how_long = borrower.guarantor_income_how_long
        brwr.guarantor_birthday = borrower.guarantor_birthday
        brwr.guarantor_ssn = borrower.guarantor_ssn
        brwr.guarantor_estimated_ficco = borrower.guarantor_estimated_ficco
        brwr.guarantor_net_worth = borrower.guarantor_net_worth
        brwr.guarantor_borrow_money = borrower.guarantor_borrow_money
        brwr.borrower_guarantor = borrower.borrower_guarantor
        brwr.hide_fields = borrower.hide_fields
        brwr.save
      end

      collaterals = detail.collateral
      collaterals.each do |collateral|
        coltrl = CopyCollateral.new
        coltrl.copy_loan_id = "#{copyLoan.id}"
        coltrl.address = collateral.address
        coltrl.city = collateral.city
        coltrl.state = collateral.state
        coltrl.postalcode = collateral.postalcode
        coltrl.estimated_value = collateral.estimated_value
        coltrl.amount_owed = collateral.amount_owed
        coltrl.mortgage_status = collateral.mortgage_status
        coltrl.gross_monthly_income = collateral.gross_monthly_income
        coltrl.purchase_price = collateral.purchase_price
        coltrl.original_purchase_price = collateral.original_purchase_price
        coltrl.source_of_value = collateral.source_of_value
        coltrl.date_last_valuation = collateral.date_last_valuation
        coltrl.date_last_bpo = collateral.date_last_bpo
        coltrl.property_generate_income = collateral.property_generate_income
        coltrl.noi_ytd = collateral.noi_ytd
        coltrl.noi_last_year = collateral.noi_last_year
        coltrl.noi_two_years_ago = collateral.noi_two_years_ago
        coltrl.noi_this_year = collateral.noi_this_year
        coltrl.noi_two_years_from_now = collateral.noi_two_years_from_now
        coltrl.transaction_type = collateral.transaction_type
        coltrl.signed_contract = collateral.signed_contract
        coltrl.contract_closing_date = collateral.contract_closing_date
        coltrl.rehab_amount = collateral.rehab_amount
        coltrl.purchase_cash_contribute = collateral.purchase_cash_contribute
        coltrl.maturity_date = collateral.maturity_date
        coltrl.refinance_cash_contribute = collateral.refinance_cash_contribute
        coltrl.vested_by = collateral.vested_by
        coltrl.original_purchase_date = collateral.original_purchase_date
        coltrl.cash_contributed = collateral.cash_contributed
        coltrl.asset_type = collateral.asset_type
        coltrl.size = coltrl.size
        coltrl.sq_footage = coltrl.sq_footage
        coltrl.acres = coltrl.acres
        coltrl.structural_size = coltrl.structural_size
        coltrl.structural_sq_footage = coltrl.structural_sq_footage
        coltrl.units = coltrl.units
        coltrl.sf_per_unit = coltrl.sf_per_unit
        coltrl.hide_fields = coltrl.hide_fields

         unless collateral.related_funds.blank?
          fnds = UseFund.all(:copy_loan_id => "#{copyLoan.id}")
          unless fnds.blank?
            # abort("#{collateral.related_funds}")
            relate = Array.new
            fnds.each do |fnd|
              if collateral.related_funds.include? fnd.fund_id
                relate << fnd.id
              end 
            end
            related_funds = relate.join(',')
            coltrl.related_funds = related_funds
          end
        end
        coltrl.save

         unless collateral.pay_offs.empty?
          collateral.pay_offs.each do |colat|
            clt = PayOff.new
            clt.copy_collateral_id = coltrl.id.to_s
            clt.amount = colat.amount
            clt.recipient = colat.recipient
            clt.save
          end
        end

      end

      shop = ShopLoan.new
      shop.loan_id = detail.id
      if @brokerLogin==true 
       shop.broker_id = @infoBroker.id
      end
      shop.user_id = @infoUser.id
      shop.copy_loan_id = copyLoan.id
      shop.shop_date = Time.now.getutc
      shop.save

        LoanUrlMailer.shop_loan(copyLoan.id).deliver
    
      if(params[:sorting] == "recent")
        recent("shop_loan")
      else
        priority("shop_loan")
      end
      #render text: "Done"
  
  end

  def email_shop_loan
    id = params[:id]
    
      detail = Loan.find(id.to_i)
      copyLoan = CopyLoan.new
      copyLoan.name = detail.name 
      copyLoan.info = detail.info
      
      if !detail.email.blank?
        copyLoan.email = detail.email
      elsif defined? detail.info['Email']
        copyLoan.email = detail.info['Email']
      end
      
      if !detail.added_by.blank?
        copyLoan.added_by = detail.added_by
      end
      if @brokerLogin==true  
        copyLoan.broker_id = @infoBroker.id
      end
      copyLoan.hide_fields = detail.hide_fields
      copyLoan.user_id = @infoUser.id
      copyLoan.loan_id = detail.id
      copyLoan.shop_date = Time.now.getutc
      copyLoan.phase = "screening"
      #copyLoan.featured = detail.id
      copyLoan.save

      funds = detail.use_of_fund
      funds.each do |fund|
        fnd = UseFund.new
        fnd.fund_id = fund.id
        fnd.use = fund.use
        fnd.amount = fund.amount
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.beneficiary = fund.beneficiary
        fnd.maturityDate = fund.maturityDate
        fnd.stats = fund.stats
        fnd.contractDate = fund.contractDate
        fnd.earnedDeposit = fund.earnedDeposit
        fnd.is_free_related = fund.is_free_related
        fnd.save
      end

      pays = detail.pay_offs
      pays.each do |pay|
        fnd = PayOff.new
        fnd.fund_id = fund.id
        fnd.use = fund.use
        fnd.amount = fund.amount
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.beneficiary = fund.beneficiary
        fnd.maturityDate = fund.maturityDate
        fnd.stats = fund.stats
        fnd.contractDate = fund.contractDate
        fnd.earnedDeposit = fund.earnedDeposit
        fnd.is_free_related = fund.is_free_related
        fnd.save
      end
      
      borrowers = detail.borrower
      borrowers.each do |borrower|
        brwr = CopyBorrower.new
        brwr.copy_loan_id = "#{copyLoan.id}"
        brwr.personal_name = borrower.personal_name
        brwr.personal_phone = borrower.personal_phone
        brwr.personal_email = borrower.personal_email
        brwr.personal_address = borrower.personal_address
        brwr.personal_city = borrower.personal_city
        brwr.personal_state = borrower.personal_state
        brwr.personal_postalcode = borrower.personal_postalcode
        brwr.personal_dob = borrower.personal_dob
        brwr.personal_ein = borrower.personal_ein
        brwr.personal_ssn = borrower.personal_ssn
        brwr.personal_gross = borrower.personal_gross
        brwr.personal_cashContribution = borrower.personal_cashContribution
        brwr.personal_monthly_income = borrower.personal_monthly_income
        brwr.personal_income_source = borrower.personal_income_source
        brwr.income_how_long = borrower.income_how_long
        brwr.estimated_fico = borrower.estimated_fico
        brwr.net_worth = borrower.net_worth
        brwr.ever_borrow_money = borrower.ever_borrow_money
        brwr.bio = borrower.bio
        brwr.business_name = borrower.business_name
        brwr.business_phone = borrower.business_phone
        brwr.business_address = borrower.business_address
        brwr.business_city = borrower.business_city
        brwr.business_state = borrower.business_state
        brwr.business_postalcode = borrower.business_postalcode
        brwr.business_type = borrower.business_type
        brwr.business_balance_sheet = borrower.business_balance_sheet
        brwr.state_of_incorporation = borrower.state_of_incorporation
        brwr.time_in_business = borrower.time_in_business
        brwr.revenue_time_period = borrower.revenue_time_period
        brwr.business_ein = borrower.business_ein
        brwr.cash_on_hand = borrower.cash_on_hand
        brwr.est_fico = borrower.est_fico
        brwr.available_credit = borrower.available_credit
        brwr.monthly_noi =  borrower.monthly_noi
        brwr.annual_noi = borrower.annual_noi
        brwr.account_recievable = borrower.account_recievable
        brwr.account_payable = borrower.account_payable
        brwr.borrower_type = borrower.borrower_type
        brwr.balance_sheet = borrower.balance_sheet
        brwr.guarantor_name = borrower.guarantor_name
        brwr.guarantor_phone = borrower.guarantor_phone
        brwr.guarantor_email = borrower.guarantor_email
        brwr.guarantor_address = borrower.guarantor_address
        brwr.guarantor_city = borrower.guarantor_city
        brwr.guarantor_state = borrower.guarantor_state
        brwr.guarantor_postalcode = borrower.guarantor_postalcode
        brwr.guarantor_monthly_income = borrower.guarantor_monthly_income
        brwr.guarantor_income_source = borrower.guarantor_income_source
        brwr.guarantor_income_how_long = borrower.guarantor_income_how_long
        brwr.guarantor_birthday = borrower.guarantor_birthday
        brwr.guarantor_ssn = borrower.guarantor_ssn
        brwr.guarantor_estimated_ficco = borrower.guarantor_estimated_ficco
        brwr.guarantor_net_worth = borrower.guarantor_net_worth
        brwr.guarantor_borrow_money = borrower.guarantor_borrow_money
        brwr.borrower_guarantor = borrower.borrower_guarantor
        brwr.hide_fields = borrower.hide_fields
        brwr.save
      end

      collaterals = detail.collateral
      collaterals.each do |collateral|
        coltrl = CopyCollateral.new
        coltrl.copy_loan_id = "#{copyLoan.id}"
        coltrl.address = collateral.address
        coltrl.city = collateral.city
        coltrl.state = collateral.state
        coltrl.postalcode = collateral.postalcode
        coltrl.estimated_value = collateral.estimated_value
        coltrl.amount_owed = collateral.amount_owed
        coltrl.mortgage_status = collateral.mortgage_status
        coltrl.gross_monthly_income = collateral.gross_monthly_income
        coltrl.purchase_price = collateral.purchase_price
        coltrl.original_purchase_price = collateral.original_purchase_price
        coltrl.source_of_value = collateral.source_of_value
        coltrl.date_last_valuation = collateral.date_last_valuation
        coltrl.date_last_bpo = collateral.date_last_bpo
        coltrl.property_generate_income = collateral.property_generate_income
        coltrl.noi_ytd = collateral.noi_ytd
        coltrl.noi_last_year = collateral.noi_last_year
        coltrl.noi_two_years_ago = collateral.noi_two_years_ago
        coltrl.noi_this_year = collateral.noi_this_year
        coltrl.noi_two_years_from_now = collateral.noi_two_years_from_now
        coltrl.transaction_type = collateral.transaction_type
        coltrl.signed_contract = collateral.signed_contract
        coltrl.contract_closing_date = collateral.contract_closing_date
        coltrl.rehab_amount = collateral.rehab_amount
        coltrl.purchase_cash_contribute = collateral.purchase_cash_contribute
        coltrl.maturity_date = collateral.maturity_date
        coltrl.refinance_cash_contribute = collateral.refinance_cash_contribute
        coltrl.vested_by = collateral.vested_by
        coltrl.original_purchase_date = collateral.original_purchase_date
        coltrl.cash_contributed = collateral.cash_contributed
        coltrl.asset_type = collateral.asset_type
        coltrl.size = coltrl.size
        coltrl.sq_footage = coltrl.sq_footage
        coltrl.acres = coltrl.acres
        coltrl.structural_size = coltrl.structural_size
        coltrl.structural_sq_footage = coltrl.structural_sq_footage
        coltrl.units = coltrl.units
        coltrl.sf_per_unit = coltrl.sf_per_unit
        coltrl.hide_fields = coltrl.hide_fields
         unless collateral.related_funds.blank?
          fnds = UseFund.all(:copy_loan_id => "#{copyLoan.id}")
          unless fnds.blank?
            # abort("#{collateral.related_funds}")
            relate = Array.new
            fnds.each do |fnd|
              if collateral.related_funds.include? fnd.fund_id
                relate << fnd.id
              end 
            end
            related_funds = relate.join(',')
            coltrl.related_funds = related_funds
          end
        end
        coltrl.save

        

      end

      shop = ShopLoan.new
      shop.loan_id = detail.id
      if @brokerLogin==true 
       shop.broker_id = @infoBroker.id
      end
      shop.user_id = @infoUser.id
      shop.copy_loan_id = copyLoan.id
      shop.shop_date = Time.now.getutc
      shop.save

        LoanUrlMailer.shop_loan(copyLoan.id).deliver
    
     flash[:notice]  = "Your loan has been shopped."
     redirect_to "/loans/shop_loan/#{copyLoan.id}"
  
  end

  ################################## Shop Loans ##################################

  def shop_loans
    if current_user.blank?
      redirect_to '/'
    end
    @loans = CopyLoan.all
    # allrms = [12, 5, 1, 30]
    # if !@loans.blank?
    #   @loans.each do |loan|
    #     # abort("#{loan.id}")

    #     allrms.each do |rm|
    #       check = Reminder.all(:num => rm, :copy_loan_id => loan.id.to_s)
           
    #       if check.blank?
    #         # abort("#{check.inspect}")
    #         reminder = Reminder.new
    #         reminder.num = rm
    #         if rm == 30
    #           reminder.units = "min"
    #         else
    #           reminder.units = "hours"
    #         end
    #         reminder.copy_loan_id = loan.id.to_s
    #         reminder.status =  0
    #         reminder.save
    #       end
    #     end

    #   end
    # end
  end

  def shop_loan
    if current_user.blank?
      flash[:alert] ='Please login to access this page.'
      redirect_to '/'
      return
    end
    #abort("#{@bucketName}") 
    #bucket = S3.create_bucket(bucket: 'testbusketxyz')
    
    @loan = CopyLoan.find_by_id(params[:id])
    # abort("#{@loan.inspect}")
    
    @funds = @loan.use_funds
    @active = LoanLender.find_by_copy_loan_id_and_status("#{params[:id]}", "active")
    
    if !@active.blank?
      etime = Time.parse(@active.end_time)
      @endt = etime.strftime("%a %b %d %Y %H:%M:%S")
    end

    @all = LoanLender.all(:copy_loan_id => params[:id].to_s)

    # abort("#{@all.inspect}")
     uInfo = User.find_by_id(@loan.info['added_by'])
     if !uInfo.blank?
        
       if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

          @bucketName = uInfo.bucket_name
          resp = S3.list_objects(bucket: "#{@bucketName}")
          @bucket_size = 0
          resp.contents.each do |object|
            @bucket_size = @bucket_size+object.size
          end
          if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
            #@max_size = 10022482
            @max_size = 1073741824
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
            
            @max_size = 5368709120
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          else
            @fileUpload = "true"
          end
        else
            @bucketName = S3_BUCKET_NAME
            @fileUpload = "true"
        end
      else
        uInfo = User.find_by_email(@loan.email)
        if !uInfo.blank?
          if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 

          @bucketName = uInfo.bucket_name
          resp = S3.list_objects(bucket: "#{@bucketName}")
          @bucket_size = 0
          resp.contents.each do |object|
            @bucket_size = @bucket_size+object.size
          end
          if !@infoBroker.blank? && @infoBroker.plan=="SOLO"
            #@max_size = 10022482
            @max_size = 1073741824
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          elsif !@infoBroker.blank? &&  @infoBroker.plan=="BUSINESS"
            
            @max_size = 5368709120
            if @bucket_size < @max_size
              @fileUpload = "true"
            else
              @fileUpload = "false"
            end
          else
            @fileUpload = "true"
          end
        else
            @bucketName = S3_BUCKET_NAME
            @fileUpload = "true"
        end
        end
      end

      if !@adminLogin.blank?
          @fileUpload = "true"
      end



    if @loan.blank?
      flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
      redirect_to '/'
      return
    end
     dateField = ['_ExpectedCloseDate', '_AppraisalDate', 'Birthday', 'DateCreated', 'LastUpdated']
    if @loan.blank?
      begin
        contact = infusionsoft.data_load('Contact', params[:id], Loan.all_fields)
      rescue Exception
        flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
        redirect_to '/'
        return;
      end
        
      if contact['_LoanName'].blank?
        contact['_LoanName'] = 'Your Awesome Loan Name Here'
      end 
      
      dateField.each do |field|
        temp = contact[field]
        if !temp.blank?
          contact[field]=temp.year.to_s+'-'+temp.month.to_s+'-'+temp.day.to_s
        end
      end

      @loan = Loan.new
      @loan.name=contact['_LoanName']
      @loan._id = contact['Id']
      @loan.info = contact
      @images = @loan.images
      @documents = @loan.get_docs
      @loan.save()
    
    else
   
     @images = Image.all(:loan_id => @loan.loan_id.to_i)
     @documents = Document.all(:loan_id => @loan.loan_id.to_i)
      #@loan.save()
    
    end
    @folders = CustomFolder.all(:loan_id => @loan.loan_id)
    @shop_lenders=LoanLender.count(:copy_loan_id => @loan.id.to_s)    
    
    @slenders = LoanLender.count(:copy_loan_id => @loan.id.to_s, :status.ne=>nil)

    @lenders = Lender.all(:delete.ne => 1)
    # abort("#{@loan.inspect}")
  end


  def edit_fields
    #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'mini_forms', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = CopyLoan.find_by_id(params[:contact_id])
            if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end

            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end


            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyLoan.find_by_id(params[:contact_id])
           @field_value = loan_info.info[params[:field_name]]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'mini_forms', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'mini_forms', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = CopyLoan.find_by_id(params[:contact_id])
             if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end
                    
            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = CopyLoan.find_by_id(params[:contact_id])
           @field_value = loan_info.info[params[:field_name]]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'mini_forms', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end


   def side_edit_fields
     #abort("#{params}")
    if(@brokerLogin==true)
       @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'side_mini_forms', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save

            loan_info = Loan.find_by_id(params[:contact_id].to_i)
            if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end

            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end


            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Loan.find_by_id(params[:contact_id].to_i)
           if params[:field_name] == "_EstimatedMarketValues"
              @field_value = loan_info.info["_EstimatedMarketValue"]
            else
              @field_value = loan_info.info[params[:field_name]]
            end
            
            # abort("#{@field_value}")
            
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
          if params[:field_name] == "FirstName" || params[:field_name] == "Email" || params[:field_name] == "Phone" 
            render partial: 'contact_mini_form', locals:
            {
              edit: false,
              contact_id: params[:contact_id],
              format_type:params[:format_type],
              field_type: params[:field_type], 
              field_label: params[:field_label], 
              field_name:params[:field_name],
              field_value:@field_value, 
              field_options:params[:field_options]
            }
          else
            render partial: 'side_mini_forms', locals:
            {
              edit: false,
              contact_id: params[:contact_id],
              format_type:params[:format_type],
              field_type: params[:field_type], 
              field_label: params[:field_label], 
              field_name:params[:field_name],
              field_value:@field_value, 
              field_options:params[:field_options]
            } 
          end
        end
    else


      if policy(Loan).update?
        

        @temp = params
        @field = params[:field]
        @format_type = params[:format_type]
        
        @field_value = params[@field]
        if @format_type == 'fd_money'
          @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
        end
        if @format_type == 'fd_date'
         # @field_value = @field_value.strftime("%m/%d/%Y")
        end
    
       
    
        if params[:edit]=='true'
          #render text: "#{@temp}"
          render partial: 'side_mini_forms', locals:
          {
            edit: true,
            contact_id: params[:contact_id],
            format_type:params[:format_type], 
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value,
            field_options:params[:field_options]
          } 
        else
         if !params.has_key?('cancel')
           #Save
            loan_info = Loan.find_by_id(params[:contact_id].to_i)
             if params[:field_name] == "_EstimatedMarketValues"
              loan_info.info['_EstimatedMarketValue'] = @field_value
            end

            unless params[:field_name] == "_EstimatedMarketValues"
              loan_info.info[params[:field_name]] =  @field_value
            end
                    
            if params[:field_name] == "Email"
              loan_info.email = @field_value
            end
            

            if params[:field_name] == "_LoanName"
              loan_info.name = @field_value
            end
            
            #abort("#{loan_info.inspect}")
            loan_info.save
         else
           #Cancel
           loan_info = Loan.find_by_id(params[:contact_id].to_i)
           @field_value = loan_info.info[params[:field_name]]
            if @format_type == 'fd_money'
             @field_value = @field_value.to_s.gsub(/[^\d\.]/, '')
            end
             
          end
    
          render partial: 'side_mini_forms', locals:
          {
            edit: false,
            contact_id: params[:contact_id],
            format_type:params[:format_type],
            field_type: params[:field_type], 
            field_label: params[:field_label], 
            field_name:params[:field_name],
            field_value:@field_value, 
            field_options:params[:field_options]
          } 
        end  
      end
    end
  end



  def edit_categorys
    lx = CopyLoan.find_by_id(params[:id])
    loan = CopyLoan.find_by_id(params[:id])
    loan.info["_LendingCategory"] = params[:_LendingCategory] 
    loanCat = CopyLoan.category_type_fields[loan.info["_LendingCategory"]]
    loan.info[loanCat] = params[loanCat]

   if params[:edit]=='true' 

      render partial: 'loan_category', locals:{contact: loan, edit: true}
      
   else
       if !params.has_key?('cancel')
        #Infusionsoft.contact_update(params[:id], { '_LendingCategory' => params[:_LendingCategory], loanCat=>params[loanCat]})
        loan.info['_LendingCategory']=params[:_LendingCategory]
        loan.info['loanCat']=params[loanCat]
        loan.save()
      else
        #temp = Infusionsoft.data_load('Contact', params[:contact_id], ['_LendingCategory', loanCat])
        loan.info["_LendingCategory"] = lx.info["_LendingCategory"]
        loan[loanCat] =  lx.info['loanCat']
      end
 
      
      render partial: 'loan_category', locals:{contact: loan, edit: false}
   end
    
  end

  def edit_loan_types
    types = CopyLoan.category_type_fields
    loanCat = params[:_LendingCategory]
    loan_type_options = CopyLoan.loan_type_options
    # render text: loan_type_options[loanCat]
    # return
    render partial: 'loan_type_forms', locals:{category: types[loanCat], options: loan_type_options[loanCat], field_value: ''}
  end

  def terms
    if params[:id] == "conditions_save"
      @success = "yes"
    else
      @success = "no"
    end
    @detail = TermCondition.find_by_type("shop_loans")
  end

  def save_conditions
    if params[:id].blank?
      trms = TermCondition.new
    else
      trms = TermCondition.find_by_id(params[:id])
    end
    trms.header = params[:header]
    trms.second_header = params[:second_header]
    trms.content = params[:content]
    trms.type = "shop_loans"
    trms.save

    redirect_to action: 'terms', id: 'conditions_save'
  end

  def delete_copy_loans
    
    ids=params[:moredata].split(",")

    ids.each do |number|
        CopyLoan.delete(number)
        ShopLoan.delete_all(:copy_loan_id => number)
        LoanLender.delete_all(:copy_loan_id => number)
        Reminder.delete_all(:copy_loan_id => number)
    end 
    
    @loans = CopyLoan.all

    render partial: 'copy_loans'
    
    flash.now[:notice] = "Loans deleted successfully"
 
  end

  def reject

    ids=params[:moredata].split(",")

    ids.each do |number|
      cloan = CopyLoan.find_by_id(number)
      cloan.reject = 1
      cloan.save
      LoanUrlMailer.reject_loan(cloan.id).deliver
    end 
    
    @loans = CopyLoan.all

    render partial: 'copy_loans'
  
  end

  def commit_to_shop

    loan_detail = CopyLoan.find_by_id("#{params[:loan_id]}")
    @alllenders = LoanLender.all(:copy_loan_id => params[:loan_id].to_s, :status => 'active')
    if !@alllenders.blank?
      @alllenders.each do |alndr|
        lx = LoanLender.find_by_id(alndr.id)
        lx.status = ""
        lx.save
      end
    end
    @allxenders = LoanLender.all(:copy_loan_id => params[:loan_id].to_s, :status => 'decline')
    if !@allxenders.blank?
      @allxenders.each do |alxndr|
        lx = LoanLender.find_by_id(alxndr.id)
        lx.status = ""
        lx.save
      end
    end
    @lenders = LoanLender.all(:copy_loan_id => params[:loan_id].to_s, :saved => 1, :order => :priority.asc) 
    start_time=Time.now.in_time_zone("Eastern Time (US & Canada)")

    if !@lenders.blank?

      serial=0
      @lenders.each do |lndr|
        # abort("#{lndr.inspect}")
        lender = LoanLender.find_by_id("#{lndr.id}")
        if lender.status != "decline"
          num = lndr.hours.to_i*60*60
          end_time = Time.now.in_time_zone("Eastern Time (US & Canada)") + num
          serial = serial+1
          lender.send_date = start_time
          lender.start_time = start_time
          lender.end_time = end_time
          lender.priority = serial
          if serial==1
            loan_detail.phase = "matching"
            loan_detail.save
              lender.status = "active"
               allreminders = Reminder.all(:copy_loan_id => "#{params[:loan_id]}" )
               if !allreminders.blank?
                allreminders.each do |remind|
                    rm = Reminder.find_by_id(remind.id)
                    rm.status = 0
                    rm.save
                end
              end
              LoanUrlMailer.lender_shop_loan(lender.id).deliver
          else
            lender.status = ""
          end
          lender.save
        end
      end
      @active = LoanLender.find_by_copy_loan_id_and_status("#{params[:loan_id]}", "active")
       # @active = LoanLender.find_by_copy_loan_id("#{params[:loan_id]}")
      # abort("#{@active.inspect}")
      if !@active.blank?
        etime = Time.parse(@active.end_time)
        @endt = etime.strftime("%a %b %d %Y %H:%M:%S")
      end
      LoanLender.delete_all(:copy_loan_id => "#{params[:loan_id]}", :saved.ne =>1)
      render partial: "active_lender"
    else
      render text: "nothing"
    end

    

  end

  def filter_shop

    ################################ Comit to shop ###################################
    info = Array.new
    linfo = Array.new

    loan_detail = CopyLoan.find_by_id("#{params[:loan_id]}")
    # if loan_detail.info['_LendingCategory'] == "Private Real Estate Loan"
    #   lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :lendingTypes => /#{loan_detail.info['_LendingTypes']}/, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :lendingTypes, :lendingStates0).all
    # elsif loan_detail.info['_LendingCategory'] == "Business Financing"
    #   lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :businessFinancingTypes => /#{loan_detail.info['_BusinessFinancingTypes']}/, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :businessFinancingTypes, :lendingStates0).all
    # elsif loan_detail.info['_LendingCategory'] == "Equity and Crowdfunding"
    #   lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :equityandCrowdFunding => /#{loan_detail.info['_EquityandCrowdFunding']}/, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :equityandCrowdFunding, :lendingStates0).all
    # elsif loan_detail.info['_LendingCategory'] == "Residential or Commercial Mortgage"
    #   lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :mortageTypes => /#{loan_detail.info['_MortageTypes']}/, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :mortageTypes).all
    # else
    #   lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :lendingTypes, :lendingStates0).all
    # end
    @alllenders = LoanLender.all(:copy_loan_id => params[:loan_id], :saved => 1)
    if @alllenders.blank?
        lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :lendingCategory => /#{loan_detail.info['_LendingCategory']}/, :lendingStates0 => /#{loan_detail.info['State3']}/).fields(:company, :loanMinDropDown, :lendingTypes, :lendingStates0).all

        if !lenders.blank?
          lenders.each do |lender|
            linfo << lender.id
          end
        end

        if !loan_detail.info['_NetLoanAmountRequested0'].blank?
          mlenders = Lender.where(:loanMaxDropDown.ne=>nil).fields(:company, :loanMaxDropDown).all
          if !mlenders.blank?
              mlenders.each do |mlender|
                if mlender.loanMaxDropDown!="No Max"
                  max = mlender.loanMaxDropDown.to_i
                  if max > loan_detail.info['_NetLoanAmountRequested0'].to_i
                    info << mlender.id
                  end
                else
                  info << mlender.id
                end
              end
          end 
        else
          info = linfo
        end
            
        if !linfo.blank? && !info.blank?
          ids = linfo&info
          @allenders = Lender.all(:id => ids)
        end 
        testid = Array.new
        if !ids.blank?
          serial=0
          ids.each do |lid|
            check = LoanLender.all(:copy_loan_id =>"#{params[:loan_id]}", :lender_id => lid.to_s)
            # abort("#{check}")
            if check.blank?
              linfo = LoanLender.new
              linfo.copy_loan_id = loan_detail.id
              linfo.lender_id = lid
              serial = serial+1
              linfo.priority = serial
              linfo.save
              testid << lid
            end
          end
        end
        
        # abort("#{@alllenders}")
        
         @alllenders = LoanLender.all(:copy_loan_id => params[:loan_id], :order => :priority.asc)
    end
       # abort("#{@alllenders.inspect}")
    
    ################################ End Comit to shop ###################################
    @loan = CopyLoan.find_by_id(params[:loan_id])
    @reminders = Reminder.all(:copy_loan_id => params[:loan_id].to_s)
    @notmatch = Lender.where(:id.ne => ids).fields(:name, :id).all
    @lndrs = Lender.all(:delete.ne => 1)

    render partial: 'commit_to_shop'
  end

  def add_more_lender
    
   

    info = Array.new
    linfo = Array.new
    loan_detail = CopyLoan.find_by_id("#{params[:loan_id]}")
    loan_detail.locations = location
    loan_detail.save 
    

    exist = LoanLender.last(:copy_loan_id => params[:loan_id])

    loc = params[:location].split(",")
    loc.each do |l|
        lenders = Lender.where(:loanMinDropDown.lte => loan_detail.info['_NetLoanAmountRequested0'].to_i,  :lendingCategory => /#{loan_detail.info['_LendingCategory']}/, :lendingStates0 => /#{l}/,:delete.ne => 1).fields(:company, :loanMinDropDown, :lendingTypes, :lendingStates0).all
        if !lenders.blank?
          lenders.each do |lender|
            linfo << lender.id
          end
        end  
    end
    

    if !loan_detail.info['_NetLoanAmountRequested0'].blank?
      mlenders = Lender.where(:loanMaxDropDown.ne=>nil,:delete.ne => 1).fields(:company, :loanMaxDropDown).all
      if !mlenders.blank?
          mlenders.each do |mlender|
            if mlender.loanMaxDropDown!="No Max"
              max = mlender.loanMaxDropDown.to_i
              if max > loan_detail.info['_NetLoanAmountRequested0'].to_i
                info << mlender.id
              end
            else
              info << mlender.id
            end
          end
      end 
    else
      info = linfo
    end
    
    if !linfo.blank? && !info.blank?
      ids = linfo&info
      if !ids.blank?
        @alllenders = Lender.all(:id => ids)
      end
    end 
    


    if !ids.blank?
      check = ""
      if exist.blank?
        serial=0
      else
        serial=exist.priority
      end
      ids.each do |lid|
        check_lender = LoanLender.all(:lender_id => lid.to_s, :copy_loan_id => loan_detail.id.to_s)
        if check_lender.blank?
          linfo = LoanLender.new
          linfo.copy_loan_id = loan_detail.id
          linfo.lender_id = lid
          serial = serial+1
          linfo.priority = serial
          linfo.save
          check = "added"
        end
      end
    end

    if check!="added"
      check="empty"
    end

    @alllenders = LoanLender.all(:copy_loan_id => loan_detail.id.to_s, :order => :priority.asc)
    if check == "empty"
      render text: check
    else
      render partial: 'shop_lenders'
    end 
  end

  def remove_by_loc
    cloan_id = params[:loan_id]
    loc = params[:location].split(",")

    loan_detail = CopyLoan.find_by_id("#{params[:loan_id]}")
    loan_detail.locations = params[:location]
    loan_detail.save 

    @lenders = LoanLender.all(:copy_loan_id => params[:loan_id].to_s)
    if !@lenders.blank?
      @lenders.each do |lendr|
       if lendr.lender.lendingStates0!=nil
         if lendr.lender.lendingStates0.include? "#{params[:remove]}"
           contains = ""
           loc.each do |lc|
             if lc != ""

                if lendr.lender.lendingStates0.include? "#{lc}"
                  contains = "yes"
                end
             end
           end
           if contains != "yes"
            LoanLender.delete(lendr.id)
          end
         end 
       end   
      end
    end
     @alllenders = LoanLender.all(:copy_loan_id => loan_detail.id.to_s, :order => :priority.asc)
     render partial: 'shop_lenders' 
 end

  def remove_lender
    loan_detail = LoanLender.find_by_id(params['lender_id'])
    LoanLender.delete(params['lender_id'])
    @alllenders = LoanLender.all(:copy_loan_id => loan_detail.copy_loan_id.to_s, :order => :priority.asc)
    render partial: 'shop_lenders'
  end

   def lender_order
    @lender_ids=params[:moredata].split(",")
    x=1
    @lender_ids.each do |number|
      lenderRecord=LoanLender.find_by_id(number)
      lenderRecord.priority=x
      lenderRecord.save
      x += 1  
    end
    render nothing: true
  end

  def save_shop_lender
    
    @allLenders = LoanLender.all(:copy_loan_id => "#{params[:loan_id]}", :order => :priority.asc)
    
    @cloan = CopyLoan.find_by_id(params[:loan_id])
    
    if !params[:location].blank?
      locations = params[:location].split(',')
    end
    @lloc = Array.new
    if !@allLenders.blank?
      i=1
      @allLenders.each do |lender|
        linfo = LoanLender.find_by_id("#{lender.id}")
        linfo.hours = params[:hours]
        linfo.priority=i
        linfo.saved = 1
        linfo.save
        i = i+1

        
        # abort("#{@allLenders}")  
        if !locations.blank?
          # abort("#{linfo.lender.lendingStates0}")  
          locations.each do |location|
            loc = linfo.lender.lendingStates0
            if !@lloc.include? "#{location}"
              if loc.include? "#{location}"
                @lloc<<location
              end
            end
          end
        end

      end

     

      if !@cloan.blank?
        unless @lloc.blank?
          location_val = @lloc.join(',')
        end
        @cloan.hours = params[:hours]
        @cloan.locations = location_val
        @cloan.search_type = params[:search_type]
        @cloan.save
      end
      msg = "added"
      
    else
      msg = "done"
    end

    render text: msg
  end

  def add_notes
    info = LoanUrl.find_by_id(params[:for_id])
    @lender_id = params[:for_id]
    @loan_id = params[:loan_id]
    @notes = Note.all(:lender_id => params[:for_id])
    render partial: 'note'
  end

  def add_lender_note
    info = LoanUrl.find_by_id(params[:lender_id])
    snotes = Note.new
    snotes.lender_id = params[:lender_id]
    snotes.loan_id = params[:loan_id]
    snotes.email = info.email
    snotes.content = params[:note]
    snotes.user_id = current_user.id
    snotes.date_added = Time.now
    snotes.save
  
    @notes = Note.all(:lender_id => params[:lender_id])  
    render partial: 'note_listing'
  end

  def add_lenders
    lender = Lender.find_by_email("#{params[:email]}")
    if !lender.blank?
      check = LoanLender.all(:lender_id => lender.id.to_s, :copy_loan_id => params[:loan_id])
    end
    if check.blank?
        last_lender= LoanLender.last(:copy_loan_id => params[:loan_id], :order => :priority.asc)
        
        if lender.blank?
          
          
          # @check = User.find_by_email(params[:email])
          
          # if !@check.blank?
          #   @roles = @check.roles
                      
          #   @names = Array.new
          #   @roles.each do |role|
          #     @names = role['name']
          #   end

          #   check_broker = @names.include? 'Lender'
          #   if check_broker==false
          #    @roles.push(Role.new(:name=>'Lender'))
          #    @check.roles=@roles
          #    @check.save
          #   end

          # else
          #   @user = User.new
            

          #   @roles = Array.new
          #   @roles.push(Role.new(:name=>'Broker'))
          #   @roles.push(Role.new(:name=>'Lender'))
          #   @user.roles = @roles
          #   @user.email = params[:email]
          #   @user.password = "12345678"
          #   @user.save

          # end

          lendr = Lender.new
          lendr.email = params[:email]
          lendr.save

          linfo = LoanLender.new
          linfo.copy_loan_id = params[:loan_id]
          linfo.lender_id = lendr.id
          if last_lender.blank?
            serial = 1
          else
            serial = last_lender.priority+1
          end
          linfo.priority = serial
          if @check.blank?
            linfo.new_user = 1
          end
          linfo.save

        else
            linfo = LoanLender.new
            linfo.copy_loan_id = params[:loan_id]
            linfo.lender_id = lender.id
            if last_lender.blank?
              serial = 1
            else
              serial = last_lender.priority+1
            end
            linfo.priority = serial
            linfo.save
        end
    end
    @alllenders = LoanLender.all(:copy_loan_id => params[:loan_id].to_s, :order => :priority.asc)
    render partial: 'shop_lenders'
     
  end

  def set_password
    
  end
  
  def remove_reminder
    Reminder.delete(params[:reminder_id])
    render text:"done"
  end 

  def add_reminder

    check = Reminder.all(:copy_loan_id=>params[:loan_id].to_s, :num=>params[:num], :units=>params[:units])
    
    if check.blank?
      remindr = Reminder.new
      remindr.copy_loan_id = params[:loan_id]
      remindr.status = 0
      remindr.num = params[:num]
      remindr.units = params[:units]
      remindr.save
    end
    
    @reminders = Reminder.all(:copy_loan_id => params[:loan_id])
    render partial: 'reminder_list'
  
  end
  
   def add_funds
    uses = params[:use]
    amnt = params[:amount]
    idx = params[:id]
    num = 0
    uses.each do |use|
      if idx[num].blank?
        # abort("no----#{idx[num]}")
        fund = UseFund.new
      else
         # abort("yes----#{idx[num]}")
        fund = UseFund.find_by_id(idx[num])
      end
      fund.use = use
      fund.amount = amnt[num]
      fund.copy_loan_id=params[:copy_loan_id]
      fund.save
      num = num+1
    end
    @funds = UseFund.all(:copy_loan_id => "#{params[:copy_loan_id]}")
    render partial: 'fund_info'
  end
  
  ################################## End Shop Loans ##################################

  def add_loan_funds
    # abort("#{params[:use].inspect}")
    uses = params[:use]
    amnt = params[:amount]
    idx = params[:id]
    num = 0
    # check = Array.new
    uses.each do |use|
      if idx[num].blank?
        fund = UseOfFund.new
      else
        fund = UseOfFund.find_by_id(idx[num])
      end
      fund.use = use
      fund.amount = amnt[num]
      fund.loan_id = params[:loan_id].to_i
      fund.beneficiary = params[:beneficiary][num]
      if use=="Payoff"
        fund.maturityDate = params[:maturityDate][num]
        fund.stats = params[:stats][num]
      elsif use == "Purchase"
        fund.contractDate = params[:contractDate][num]
        fund.earnedDeposit = params[:earnedDeposit][num]
      end
      if params[:is_free_related]
        fund.is_free_related = params[:is_free_related][num]
      end
       # check << fund
       fund.save
      
      num = num+1
    
    end
    # abort("#{check.inspect}")
    @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)

    render partial: 'fund_info'
  end

  def copy_add_loan_funds
    # abort("#{params[:use].inspect}")
    uses = params[:use]
    amnt = params[:amount]
    idx = params[:id]
    num = 0
    # check = Array.new
    uses.each do |use|
      if idx[num].blank?
        fund = UseFund.new
      else
        fund = UseFund.find_by_id(idx[num])
      end
      fund.use = use
      fund.amount = amnt[num]
      fund.copy_loan_id = params[:loan_id]
      fund.beneficiary = params[:beneficiary][num]
      if use=="Payoff"
        fund.maturityDate = params[:maturityDate][num]
        fund.stats = params[:stats][num]
      elsif use == "Purchase"
        fund.contractDate = params[:contractDate][num]
        fund.earnedDeposit = params[:earnedDeposit][num]
      end
      fund.is_free_related = params[:is_free_related][num]
       # check << fund
       fund.save
      
      num = num+1
    
    end
    # abort("#{check.inspect}")
    @funds = UseFund.all(:copy_loan_id => params[:loan_id])

    render partial: 'fund_info'
  end



  def loan_funds
    @col = Collateral.find_by_id(params[:collateral_id])
      @relat_arr = Array.new
    unless @col.related_funds.blank?
      @relat_arr = @col.related_funds.split(',')
    end

    @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)
    @collateral = params[:collateral_id]
    render partial: 'edit_relation'  
  end

  def copy_loan_funds
    @col = CopyCollateral.find_by_id(params[:collateral_id])
      @relat_arr = Array.new
    unless @col.related_funds.blank?
      @relat_arr = @col.related_funds.split(',')
    end

    @funds = UseFund.all(:copy_loan_id => params[:loan_id])
    @collateral = params[:collateral_id]
    render partial: 'copy_edit_relation'  
  end

  def add_funds_relation
    
    related = params[:related_funds].join(',')
    collat = Collateral.find_by_id(params[:collateral_id])
    collat.related_funds = related
    collat.save

    @collateral = Collateral.find_by_id(collat.id)
    render partial: 'related_funds'  
  end

  def add_copyfunds_relation
    
    related = params[:related_funds].join(',')
    collat = CopyCollateral.find_by_id(params[:collateral_id])
    collat.related_funds = related
    collat.save

    @collateral = CopyCollateral.find_by_id(collat.id)
    render partial: 'copy_related_funds'  
  end

  def add_payoff
    amounts = params[:amount]
    recipients = params[:recipient]
    idx = params[:id]
    num = 0
    amounts.each do |amount|
      if idx[num].blank?
        payoff = PayOffAmount.new
      else
        payoff = PayOffAmount.find_by_id(idx[num])
      end
      payoff.amount = amount
      payoff.recipient = recipients[num]
      payoff.loan_id=params[:loan_id].to_i
      payoff.save
      num = num+1
    end

    @payoffs = PayOffAmount.all(:loan_id => params[:loan_id].to_i)
    # abort("#{@payoffs.inspect}")
    render partial: 'payoff_info'
  end

  def add_copy_payoff
    amounts = params[:amount]
    recipients = params[:recipient]
    idx = params[:id]
    num = 0
    amounts.each do |amount|
      if idx[num].blank?
        payoff = PayOff.new
      else
        payoff = PayOff.find_by_id(idx[num])
      end
      payoff.amount = amount
      payoff.recipient = recipients[num]
      payoff.copy_loan_id=params[:loan_id]
      payoff.save
      num = num+1
    end

    @payoffs = PayOff.all(:copy_loan_id => params[:loan_id])
    # abort("#{@payoffs.inspect}")
    render partial: 'payoff_info'
  end

  def all_funds
    @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)
    render partial: 'edit_funds'
  end

  def all_shop_funds
    @funds = UseFund.all(:copy_loan_id => params[:loan_id].to_s)
    render partial: 'edit_funds'
  end

  def search
      #################### Check Login #######################
      roles=current_user.roles
      @names = Array.new
      roles.each do |role|
        @names << role.name
      end
      @checkAdmin = @names.include?('Admin')
      @checkBroker = @names.include?('Broker')
      
    #################### End Check Login #######################

    if @checkAdmin!=true && @checkBroker==true
      @broker_emails = Array.new
      broker= Broker.find_by_email(current_user.email)
      brokId=broker.id.to_s
      @broker_emails << broker['email']
      reqs = Request.all(:broker_id => brokId, :status =>1)
      unless reqs.blank?
        reqs.each do |req|
          broker_req = Broker.find(req.subbroker_id)
          unless broker_req.blank?
           @broker_emails << broker_req['email']
          end
        end
      end
      @lns = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :sort_id.asc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10)
      @lns = Loan.all(:delete.ne => 1, :archived.ne => true, :order => :sort_id.asc)
    end
    @ids =  Array.new
    @names = Array.new

    @searchtxt = params['search_txt'].downcase

    if !@lns.blank?
      @lns.each do |loan|
        if !loan.name.blank?
          @lname = loan.name.downcase
          if @lname.include? "#{@searchtxt}"
            @names << loan.name
            @ids << loan.id
          end
        else
          @lname = "no loan title"
          if @lname.include? "#{@searchtxt}"
              @names << loan.name
              @ids << loan.id
            end
        end
        
        
        if defined? loan.info['State3']
          
          if loan.info['State3']!=nil
            @lstate = loan.info['State3'].downcase
            if @lstate.include? "#{@searchtxt}"
              @ids << loan.id
            end
          end
        end

        if defined? loan.info['City3']
          if loan.info['City3']!=nil
            @lcity = loan.info['City3'].downcase
            if @lcity.include? "#{@searchtxt}"
              @ids << loan.id
            end
          end
        end

        if defined? loan.info['_NetLoanAmountRequested0']
          if loan.info['_NetLoanAmountRequested0']!=nil
            @lamnt = loan.info['_NetLoanAmountRequested0'].to_s
            if @lamnt.include? "#{params['search_txt']}"
              @ids << loan.id
            end
          end
        end

      end
    end
    # @search = "yes"
    # @loans= Loan.all(:id => @ids, :order => :id.desc)

    if params['sorting_type'] == "recent"
      
        if @ids.blank?
          @loans = Array.new
          @empty =  "No Loan Found."
        else
         @loans = Loan.paginate(:id=>@ids, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
         # @loans = Loan.all(:id=>ids, :order => :id.desc)
        
          @total_loans = Loan.count(:id=>@ids);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
        else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
        end



      end


      flash.now[:notice] = "Searching by recent Loans"
      render partial: 'loans/all_loans'

    elsif params['sorting_type']=="incomplete_loan"
      
      if @ids.blank?
          @loans = Array.new
          @empty =  "No Loan Found."
        else
         @loans = Loan.paginate(:id=>@ids, :incomplete=>1, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
         # @loans = Loan.all(:id=>ids, :order => :id.desc)
        
          @total_loans = Loan.count(:id=>@ids);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
        else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
        end



      end


      flash.now[:notice] = "Searching by Incomplete Loans"
      render partial: 'loans/all_loans'

    else

      if @ids.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans = Loan.paginate(:id=>@ids, :on_priority=>1, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans, :order => :priority_num.asc)
        # @loans = Loan.all(:id=>ids, :on_priority=>1, :order => :priority_num.desc)
        @total_loans = Loan.count(:id=>@ids, :on_priority=>1);

         unless params[:records].blank?
            @partition = @total_loans/ params[:records].to_i
            @partitions = @partition.round
            @check = @partition*params[:records].to_i
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = params[:records]
            @page = params[:page]
          else
            @partition = @total_loans/ 10
            @partitions = @partition.round
            @check = @partition*10
            if @check<@total_loans
              @partitions = @partition + 1
            end
            @records = 10
            @page = 1
           end
        end

        flash.now[:notice] = "Searching by priority"
        render partial: 'loans/sort_loans'

      end
    # render partial: 'loans/all_loans'
  end

  def delete_pdf
    pdfInfo = Pdf.find_by_id("#{params[:pdf_id]}")
    filename = "#{pdfInfo.file_name}.pdf"
    path = 'pdfs/'+filename
    # abort("#{path}")
    File.delete(path) if File.exist?(path)
    Pdf.delete(params[:pdf_id])
    LoanPdf.delete_all(:pdf_id => params[:pdf_id])
    render text:"done"
  end

  def edit_picture
    @image = Image.find_by_id("#{params[:imgId]}")
    @imgPath = Rails.root.join('public', 'temp', @image.name)
    render partial: 'edit_picture'
  end

  def save_edit_pic
  image = Image.find_by_id(params[:img_id])

  if params[:if_edit] == "yes"
     

       loan=Loan.find_by_id(image.loan_id.to_i)
     if (loan.info['added_by'].blank?)
        
        if(loan.email.blank?)
          uInfo = nil;
        else
          uInfo = User.find_by_email(loan.email)
        end

     else
         uInfo = User.find_by_id(loan.info['added_by'])

     end

     # abort("#{uInfo.inspect}")

     if(uInfo.nil?)
    
        @bucketName = S3_BUCKET_NAME
    
     else
      # || uInfo.bucket_name.nil?
      @bucketName = (uInfo.bucket_name.nil?) ? S3_BUCKET_NAME : uInfo.bucket_name

     end

     
     newtime= Time.now.strftime("%m-%d-%y_%H-%M-%S")
     file_name = "#{newtime}.png"
     urll= params[:url]
     
     imgxPath = urll.gsub("data:image/png;base64,", '')
     img_path =   Base64.decode64("#{imgxPath}")
     File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|

     # contents = uploaded_io.read
     file.write img_path
        
        
        # Make an object in your bucket for your upload
        key_name = loan.id.to_s+'/'+file_name
        
      
          obj = S3.put_object(
                 acl: "public-read",
                 bucket: S3_BUCKET_NAME,
                 key: key_name,
                 body: img_path
                 )
       
          @check = false
          
          
         
              ext =  file_name.split('.').last.downcase 
              
              image.name="#{file_name}"
              image.file_id = "#{key_name}"
              if defined? my_bucket  
                  image.url = "https://s3-us-west-2.amazonaws.com/#{my_bucket}/#{loan.id}/#{file_name}"
              else
                  image.url = "https://s3-us-west-2.amazonaws.com/#{S3_BUCKET_NAME}/#{loan.id}/#{file_name}"
              end
              image.save
               
              
        
      end
  end
    # abort("#{image.inspect}")
    redirect_to action: 'show', id: image.loan_id
  end

  def add_new_borrowerx
     num = Borrower.count(:loan_id => params[:loan_id].to_i, :order => :id.asc)
    @serial = num+1 
    
    borrower = Borrower.new
    borrower.loan_id = params[:loan_id].to_i
    borrower.save

    @borwr = Borrower.find_by_id(borrower.id)
    


    render partial: 'next_borrower'
  end

  def add_new_borrower
    
    borrower = Borrower.new
    borrower.loan_id = params[:loan_id].to_i
    borrower.save

    @borrowers = Borrower.all(:loan_id => params[:loan_id].to_i, :order => :id.desc)
    
    unless @borrowers.blank?

      @brwrId = Array.new
      @borrowers.each do |borrower|
         @brwrId << "personal_loc_#{borrower.id}"
         @brwrId << "business_loc_#{borrower.id}"
         @brwrId << "guarantor_loc_#{borrower.id}"
      end
    end

    render partial: 'next_borrower'
  end
  
  def add_new_collateralx
    num = Collateral.count(:loan_id => params[:loan_id].to_i, :order => :id.asc)
    @serial = num+1 
    
    collateral = Collateral.new
    collateral.loan_id = params[:loan_id].to_i
    collateral.save

    @collateral = Collateral.find_by_id(collateral.id)
    @loan = Loan.find_by_id(params[:loan_id].to_i)

    render partial: 'next_collateral'
  end

  def add_new_collateral
    
    collateral = Collateral.new
    collateral.loan_id = params[:loan_id].to_i
    collateral.save

    @collaterals = Collateral.all(:loan_id => params[:loan_id].to_i, :order => :id.desc)
    @loan = Loan.find_by_id(params[:loan_id].to_i)

    unless @collaterals.blank?

      @brwrId = Array.new
      @collaterals.each do |collateral|
         @brwrId << "collateral_loc_#{collateral.id}"
      end
    end

    render partial: 'next_collateral'
  end

  def add_copy_borrowerx
    num = CopyBorrower.count(:copy_loan_id => params[:loan_id], :order => :id.asc)
    @serial = num+1 
    
    borrower = CopyBorrower.new
    borrower.copy_loan_id = params[:loan_id]
    borrower.save

    @borwr = CopyBorrower.find_by_id(borrower.id)
   

    render partial: 'next_copy_borrower'
  end

  def add_copy_borrower
    
    borrower = CopyBorrower.new
    borrower.copy_loan_id = params[:loan_id]
    borrower.save

    @borrowers = CopyBorrower.all(:copy_loan_id => params[:loan_id], :order => :id.desc)
    render partial: 'next_copy_borrower'
  
  end

  def add_copy_collateralx
    num = CopyCollateral.count(:copy_loan_id => params[:loan_id], :order => :id.asc)
    @serial = num+1 
    
    collateral = CopyCollateral.new
    collateral.copy_loan_id = params[:loan_id]
    collateral.save

    @collateral = CopyCollateral.find_by_id(collateral.id)
    @loan = CopyLoan.find_by_id(params[:loan_id])
   

    render partial: 'next_copy_collateral'
  end

  def add_copy_collateral
    
    collateral = CopyCollateral.new
    collateral.copy_loan_id = params[:loan_id]
    collateral.save

    @collaterals = CopyCollateral.all(:copy_loan_id => params[:loan_id], :order => :id.desc)
    
    @loan = CopyLoan.find_by_id(params[:loan_id])
   

    render partial: 'next_copy_collateral'
  end

  ################# Incomplete Loans #######################
  def incomplete_fd_loans
     now_time = Time.now
    # adjusted_datetime = Time.now
    adjusted_datetime = (now_time - 1.hours).to_time
     @loans = Loan.all(:created_at => {'$lt' => adjusted_datetime}, :incomplete => 1, :complete_email.ne => 1)
    unless @loans.blank?
      @loans.each do |loan|
          loan.complete_email = 1
          loan.save
          unless loan.fd_id.blank?
            unless loan.email.blank?
              LoanUrlMailer.complete_this_loan(loan.id).deliver
              #Make Email
              LoanUrlMailer.incomplete_loan(loan.id).deliver
            end
          end
      end
    end

    render text: "done"
  end 
  ################# Incomplete Loans #######################

  def free_clear
    loanInfo = Loan.find_by_id(params[:loan_id].to_i)
    loanInfo.info['free_clear'] = params['free_clear']
    loanInfo.save

    render text: "done"
  end

  def is_broker
    loanInfo = Loan.find_by_id(params[:loan_id].to_i)
    loanInfo.info['isBroker'] = params['isBroker']
    loanInfo.save

    render text: "done"
  end

  def copy_free_clear
    loanInfo = CopyLoan.find_by_id(params[:loan_id])
    loanInfo.info['free_clear'] = params['free_clear']
    loanInfo.save

    render text: "done"
  end

  def check_mail
    LoanUrlMailer.test_email("Pritika").deliver
    render text: "done"
  end

  def add_related_fund
    # colInfo = Collateral.find_by_id(params[:collateral_id])
    @colid = params[:collateral_id]
    @loanId = params[:loan_id]
    render partial: 'add_related_fund'
  end

  def add_fund_related

      fund = UseOfFund.new
      fund.use = params[:use]
      fund.amount = params[:amount]
      fund.loan_id = params[:loan_id].to_i
      fund.beneficiary = params[:beneficiary]
      if params[:use]=="Payoff"
        fund.maturityDate = params[:maturityDate]
        fund.stats = params[:stats]
      elsif params[:use] == "Purchase"
        fund.contractDate = params[:contractDate]
        fund.earnedDeposit = params[:earnedDeposit]
      end
      fund.save



    collat = Collateral.find_by_id(params[:collateral_id].to_s)
    relate_funds = collat.related_funds
    if relate_funds!=""
      collat.related_funds = "#{relate_funds},#{fund.id}"
    else
      collat.related_funds = "#{fund.id}"
    end
    collat.save

    
    @collateral = Collateral.find_by_id(params[:collateral_id])
    render partial: 'related_funds'  
  end

  def after_related_funds
    @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)
    render partial: 'fund_info'
  end

  def remove_related_funds
    @collateral = Collateral.find_by_id(params[:collateral_id])
    relate_funds = @collateral.related_funds.split(',')
    relate_funds.delete("#{params[:fund_id]}")
    if relate_funds.blank?
      @collateral.related_funds = ""
    else
      @collateral.related_funds = relate_funds.join(',')
    end
    @collateral.save
  
    render partial: 'related_funds'
  end

  def edit_all_funds
     @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)
     @loan_id = params[:loan_id]
     render partial: 'edit_loan_funds'
  end

  def new_loan

    @last_loan = Loan.last
    @new_id = @last_loan.id+1
    dbLoan = Loan.new()
    if params[:_LoanName].blank?
      dbLoan.name = 'Awesome Loan Name'
    else
      dbLoan.name=params[:_LoanName]
    end

    current_user.roles.each do |role|
      if dbLoan.created_by_info.blank?
        if role.name == "Admin"
          dbLoan.created_by_info = "Admin"
        elsif current_user.is_admin == true
          dbLoan.created_by_info = "Admin"
        elsif role.name == "Broker"
          dbLoan.created_by_info = "Broker"
        else
          dbLoan.created_by_info = "Broker"
        end
      end
    end
    dbLoan.created_by_email = current_user.email
    dbLoan.created_by_name = current_user.name
    
    dbLoan.email=current_user.email
    dbLoan.id = @new_id
    dbLoan.info = params
    time_nw = Time.now
    dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
    dbLoan.created_at=Time.now
    dbLoan.save
    
    render text: @new_id
  
  end

  def save_personal_address
    borwr = Borrower.find_by_id(params[:borrower_id])
    
    borwr.personal_address = params[:personal_address]
    borwr.personal_state = params[:personal_state]
    borwr.personal_city = params[:personal_city]
    borwr.personal_postalcode = params[:personal_postalcode]
    borwr.save

    @borrower =  Borrower.find_by_id(params[:borrower_id])

    render partial: 'personal_address'
  end 



   def save_business_address
    borwr = Borrower.find_by_id(params[:borrower_id])
    
    borwr.business_address = params[:business_address]
    borwr.business_state = params[:business_state]
    borwr.business_city = params[:business_city]
    borwr.business_postalcode = params[:business_postalcode]
    borwr.save

    @borrower =  Borrower.find_by_id(params[:borrower_id])

    render partial: 'business_address'
  end 

  def save_guarantor_address
    borwr = Borrower.find_by_id(params[:borrower_id])
    # abort("#{borwr.inspect}")
    borwr.guarantor_address = params[:guarantor_address]
    borwr.guarantor_state = params[:guarantor_state]
    borwr.guarantor_city = params[:guarantor_city]
    borwr.guarantor_postalcode = params[:guarantor_postalcode]
    borwr.save

    @borrower =  Borrower.find_by_id(params[:borrower_id])

    render partial: 'guarantor_address'
  end 

  def save_collateral_address

    collateral = Collateral.find_by_id(params[:collateral_id])
    
    collateral.address = params[:address]
    collateral.state = params[:state]
    collateral.city = params[:city]
    collateral.postalcode = params[:postalcode]
    collateral.save

    @collateral =  Collateral.find_by_id(params[:collateral_id])

    render partial: 'collateral_address'
  
  end 

  def fetch_location_map

    @collateral = Collateral.find_by_id(params[:collateral_id])
    render partial: 'collateral_map'
  
  end 

  def test_api
    
  end

  def save_loan_data
    # abort("#{params.inspect}")
    @loan = Loan.find_by_id(params[:loan_id].to_i)
    if params[:ftype] == "money"
      params.each do |key, value| 
        
          if key != "loan_id" && key != "ftype" && key != "controller" && key != "action"
           
            if value != ""
              @fval = value.to_s.gsub(/[^\d\.]/, '')
              @field_val = number_to_currency(@fval)
            else
              @field_val = value
            end
            @loan.info[key] = @field_val
          end
        
      end
    else
       params.each do |key, value| 
          if key != "loan_id" && key != "ftype" && key != "controller" && key != "action"
            @field_val = value
            @loan.info[key] = @field_val
          end
       end
    end 
    
    @loan.save 
    render text: "#{@field_val}"

  end

  def fetch_loan_data
    # abort("#{params.inspect}")
    loan_id = params[:loan_id].to_i
    @loan = Loan.find_by_id(loan_id)
    params.delete :action
    params.delete :controller
    @info_arr = @loan.info
    @innfo_arr = @info_arr.merge(params)
    @loan.info = @innfo_arr

    if @loan.info['gross_loan_amount'].blank?
    unless @loan.info['_NetLoanAmountRequested0'].blank?
      @loan.info['gross_loan_amount'] = @loan.info['_NetLoanAmountRequested0']
      @loan.save
    end
   end
   
   if @loan.info['acash_to_contribute'].blank?
    unless @loan.info['purchase_cash_contribute'].blank?
      @loan.info['acash_to_contribute'] = @loan.info['purchase_cash_contribute']
      @loan.save
    end
   end

   if @loan.info['apurchase_price'].blank?
    unless @loan.info['purchase_price'].blank?
      @loan.info['apurchase_price'] = @loan.info['purchase_price']
      @loan.save
    end
   end
   
   unless @loan.info['_NetLoanAmountRequested0'].blank?
    unless @loan.info['_EstimatedMarketValue'].blank?
      if @loan.info['as_is_ltv'].blank?
        ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
        @ultv = ltv *100
        @loan.info['as_is_ltv'] = @ultv.round(2)
        @loan.save
      end
    end
   end
    @loan.save

    @loanInfo = Loan.find_by_id(loan_id)
    render json: @loanInfo.info
  end

  def save_copyloan_data
    # abort("#{params.inspect}")
    @loan = CopyLoan.find_by_id(params[:loan_id])
    # abort("#{@loan.info}")
    if params[:ftype] == "money"
      params.each do |key, value| 
        
          if key != "loan_id" && key != "ftype" && key != "controller" && key != "action"
           
            if value != ""
              @fval = value.to_s.gsub(/[^\d\.]/, '')
              @field_val = number_to_currency(@fval)
            else
              @field_val = value
            end
            @loan.info[key] = @field_val
          end
        
      end
    else
       params.each do |key, value| 
          if key != "loan_id" && key != "ftype" && key != "controller" && key != "action"
            @field_val = value
            @loan.info[key] = @field_val
          end
       end
    end 

    @loan.save 
    render text: "#{@field_val}"

  end

  def fetch_copyloan_data
    # abort("#{params.inspect}")
    loan_id = params[:loan_id]
    @loan = CopyLoan.find_by_id(loan_id)
    params.delete :action
    params.delete :controller
    @info_arr = @loan.info
    @innfo_arr = @info_arr.merge(params)
    @loan.info = @innfo_arr

    if @loan.info['gross_loan_amount'].blank?
    unless @loan.info['_NetLoanAmountRequested0'].blank?
      @loan.info['gross_loan_amount'] = @loan.info['_NetLoanAmountRequested0']
      @loan.save
    end
   end
   
   if @loan.info['acash_to_contribute'].blank?
    unless @loan.info['purchase_cash_contribute'].blank?
      @loan.info['acash_to_contribute'] = @loan.info['purchase_cash_contribute']
      @loan.save
    end
   end

   if @loan.info['apurchase_price'].blank?
    unless @loan.info['purchase_price'].blank?
      @loan.info['apurchase_price'] = @loan.info['purchase_price']
      @loan.save
    end
   end
   
   unless @loan.info['_NetLoanAmountRequested0'].blank?
    unless @loan.info['_EstimatedMarketValue'].blank?
      if @loan.info['as_is_ltv'].blank?
        ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
        @ultv = ltv *100
        @loan.info['as_is_ltv'] = @ultv.round(2)
        @loan.save
      end
    end
   end
    @loan.save

    @loanInfo = CopyLoan.find_by_id(loan_id)
    render json: @loanInfo.info
  end

  def send_email
    loanInfo = Loan.find_by_id(params[:loan_id].to_i)
    contact_email = loanInfo.info['Email']
    unless contact_email.blank?
      LoanUrlMailer.fund_email(loanInfo).deliver
      render text: "Email has been sent."
    else
      render text: "Please enter contact email first."
    end
  end

  def loan_bar_chart
    @funds = UseOfFund.all(:loan_id => 3975)
    
    unless @funds.blank?
        @uses = Array.new
        @amounts = Array.new
        @uses<<""
        @amounts<<""
        @funds.each do |fund|
          if fund.use.blank?
            @uses<< ""
          else
            @uses<< fund.use
          end

          if fund.amount.blank?
            @amounts << "0"
          else
            @amounts<< fund.amount
          end
          
        end
    end

  end

  def edit_save_loan_data
    @loan = Loan.find_by_id(params[:loan_id].to_i)

    @collaterals = Collateral.all(:loan_id => @loan.id)
    collateral_acres = 0
    collateral_secondarysize = 0
    collateral_total_gross = 0
    noi_ytd = 0

    acres = Array.new
    sq_footage = Array.new
    gross = Array.new
    noi_ytd_arr = Array.new

    unless @collaterals.blank?
      @collaterals.each do |collateral|
       
        
        unless collateral.gross_monthly_income.blank?
          gross << collateral.gross_monthly_income
          collateral_total_gross += collateral.gross_monthly_income.to_f
        end

        unless collateral.noi_ytd.blank?
          noi_ytd_arr << collateral.noi_ytd
          noi_ytd += collateral.noi_ytd.to_f
        end
        
        if collateral.size=="Acres"
          acres << collateral.acres
          collateral_acres += collateral.acres.to_f
        end
        
        if collateral.size=="Sq Footage"
          sq_footage << collateral.sq_footage
          collateral_secondarysize += collateral.sq_footage.to_f
        end
      

      end
    end

    year = Time.now.year

    start_date = Date.parse "#{year}-01-01 14:46:21 +0100"
    end_date =  Date.parse "#{year}-12-31 14:46:21 +0200"
    @days = (end_date - start_date).to_i + 1

    today_date=Time.now
    # abort("#{today_date}")
    
    check_start_date = Date.parse "#{@loan.created_date}"
    check_end_date = Date.parse "#{today_date}"
    @check_days = (check_end_date - check_start_date).to_i + 1

   ###################### New ################################
  
    unless @loan.total_gross.blank?
       grossincome = (@loan.total_gross.to_f/@check_days)*@days
       @loan.info['annual_as_is_gross_income'] =  number_to_currency(grossincome.round(2))
       @loan.save

       @return = @loan.info['annual_as_is_gross_income']
    end

    unless @loan.total_noi_ytd.blank?
       noiytd = (@loan.total_noi_ytd.to_f/@check_days)*@days
       @loan.info['annual_as_is_noi'] =  number_to_currency(noiytd.round(2))
       @loan.save

       @return = @loan.info['annual_as_is_gross_income']
    end
    
    unless @loan.total_primary_sf.blank?
      @loan.info['land_square_footage'] = @loan.total_primary_sf.to_f*43560
      @loan.save

      @return = @loan.info['land_square_footage']
    end
     
    unless @loan.total_secondary_size.blank?
      @loan.info['structural_square_footage'] = @loan.total_secondary_size
      @loan.save

      @return = @loan.info['structural_square_footage']
    end

    @loan_info = Loan.find_by_id(params[:loan_id].to_i)
    ###################### End New ################################
    ############### Convert Output To JSON ######################
    render json: @loan_info.info
  end

  def edit_analysis_data
    @loan = Loan.find_by_id(params[:loan_id].to_i)
    @collaterals = Collateral.all(:loan_id => params[:loan_id].to_i)
    @col_acres = CollateralAcres.all(:loan_id => params[:loan_id].to_i)
    @col_sqs = CollateralSqfootage.all(:loan_id => params[:loan_id].to_i) 
    @col_noi = CollateralNoi.all(:loan_id => params[:loan_id].to_i)
    @col_gross = CollateralGross.all(:loan_id => params[:loan_id].to_i) 
    
    
    @colacres = Hash.new
    @col_acres.each do |col_acre|
      @colacres[col_acre.collateral_id.to_s] = col_acre.value
    end
    
    @colsqs = Hash.new
    @col_sqs.each do |col_sq|
      @colsqs[col_sq.collateral_id.to_s] = col_sq.value
    end
    
    @colnois = Hash.new
    @col_noi.each do |col_noi|
      @colnois[col_noi.collateral_id.to_s] = col_noi.value
    end

    @colgross = Hash.new
    @col_gross.each do |col_gros|
      @colgross[col_gros.collateral_id.to_s] = col_gros.value
    end 
    
    render partial: "update_analysis"
  
  end

  def update_fields

    @loan = Loan.find_by_id(params[:loan_id].to_i)

    year = Time.now.year

    start_date = Date.parse "#{year}-01-01 14:46:21 +0100"
    end_date =  Date.parse "#{year}-12-31 14:46:21 +0200"
    @days = (end_date - start_date).to_i + 1

    today_date=Time.now

    if params['name'] == "acres"
      
      update_acre = CollateralAcres.find_by_collateral_id(params[:id])
      if update_acre.blank?
        new_acre = CollateralAcres.new
        new_acre.collateral_id = params[:id]
        new_acre.loan_id = params[:loan_id].to_i
        new_acre.value = params[:value]
        new_acre.save
      else
        update_acre.value = params[:value]
        update_acre.save
      end

      @col_acres = CollateralAcres.all(:loan_id => params[:loan_id].to_i)
       total_acres = 0
      unless @col_acres.blank?
        @col_acres.each do |acre|
          total_acres += acre.value.to_f
        end
      end

      
      @loan.total_primary_sf = total_acres
      @loan.info['land_square_footage'] = total_acres*43560
      @loan.save

    elsif params['name'] == "sq_footage"

      update_footage = CollateralSqfootage.find_by_collateral_id(params[:id])
      if update_footage.blank?
        new_footage = CollateralSqfootage.new
        new_footage.loan_id = params[:loan_id].to_i
        new_footage.collateral_id = params[:collateral_id]
        new_footage.value = params[:value]
        new_footage.save
      else
        update_footage.value = params[:value]
        update_footage.save
      end
      
      @all_footages = CollateralSqfootage.all(:loan_id => params[:loan_id].to_i)
      total_footage = 0
      unless @all_footages.blank?
        @all_footages.each do |footage|
          total_footage += footage.value.to_f
        end
      end

      @loan.total_secondary_size = total_footage
      @loan.info['structural_square_footage'] = total_footage
      @loan.save

    elsif params['name'] == "gross"

      update_gross = CollateralGross.find_by_collateral_id(params[:id])
      if update_gross.blank?
        new_gross = CollateralGross.new
        new_gross.loan_id = params[:loan_id].to_i
        new_gross.collateral_id = params[:collateral_id]
        new_gross.value = params[:value]
        new_gross.save
      else
        update_gross.value = params[:value]
        update_gross.save
      end

      @all_gross = CollateralGross.all(:loan_id => params[:loan_id].to_i)
      total_gross = 0
      unless @all_gross.blank?
        @all_gross.each do |gross|
          total_gross += gross.value.to_f
        end
      end

     

      check_start_date = Date.parse "#{@loan.info['created_date_gross']}"
      check_end_date = Date.parse "#{today_date}"
      @check_days = (check_end_date - check_start_date).to_i + 1
      @loan.info['gross_days'] = @check_days
      grossincome = (total_gross.to_f/@check_days)*@days
      # abort("#{@loan.info['created_date_gross']} #{total_gross}/#{@check_days}*#{@days} = #{grossincome}")
      @loan.total_gross = total_gross.to_f
      @loan.info['annual_as_is_gross_income'] =  number_to_currency(grossincome.round(2))
      # abort("#{@loan.info['annual_as_is_gross_income']}")
      @loan.save
      # abort("#{@loan.info['annual_as_is_gross_income']}")
    elsif params['name'] == "noi"

      update_noi = CollateralNoi.find_by_collateral_id(params[:id])
      if update_noi.blank?
        new_noi = CollateralNoi.new
        new_noi.loan_id = params[:loan_id].to_i
        new_noi.collateral_id = params[:collateral_id]
        new_noi.value = params[:value]
        new_noi.save
      else
        update_noi.value = params[:value]
        update_noi.save
      end

      @all_noi = CollateralNoi.all(:loan_id => params[:loan_id].to_i)
      total_noi = 0
      unless @all_noi.blank?
        @all_noi.each do |noi|
          total_noi += noi.value.to_f
        end
      end

     

      check_start_date = Date.parse "#{@loan.info['created_date_noi']}"
      check_end_date = Date.parse "#{today_date}"
      @check_days = (check_end_date - check_start_date).to_i + 1

      noiincome = (total_noi.to_f/@check_days)*@days
      @loan.total_noi_ytd = total_noi.to_f
      @loan.info['annual_as_is_noi'] =  number_to_currency(noiincome.round(2))
      @loan.save

    elsif params['name'] == "ncreated_date"

      @all_noi = CollateralNoi.all(:loan_id => params[:loan_id].to_i)
      total_noi = 0
      unless @all_noi.blank?
        @all_noi.each do |noi|
          total_noi += noi.value.to_f
        end
      end

      @loan.info['created_date_noi'] = params[:value]

      check_start_date = Date.parse "#{params[:value]}"
      check_end_date = Date.parse "#{today_date}"
      @check_days = (check_end_date - check_start_date).to_i + 1
      # abort("#{check_start_date}-- #{check_end_date} -- #{@check_days}")
      @loan.info['noi_days'] = @check_days
      noiincome = (total_noi.to_f/@check_days)*@days
      @loan.total_noi_ytd = total_noi.to_f
      @loan.info['annual_as_is_noi'] =  number_to_currency(noiincome.round(2))
      @loan.save

    elsif params['name'] == "gcreated_date"
      @all_gross = CollateralGross.all(:loan_id => params[:loan_id].to_i)
      total_gross = 0
      unless @all_gross.blank?
        @all_gross.each do |gross|
          total_gross += gross.value.to_f
        end
      end

     @loan.info['created_date_gross'] = params[:value]

      check_start_date = Date.parse "#{params[:value]}"
      check_end_date = Date.parse "#{today_date}"
      @check_days = (check_end_date - check_start_date).to_i + 1
      # abort("#{check_start_date}-- #{check_end_date} -- #{@check_days}")
      @loan.info['gross_days'] = @check_days
      grossincome = (total_gross.to_f/@check_days)*@days
      @loan.total_gross = total_gross.to_f
      @loan.info['annual_as_is_gross_income'] =  number_to_currency(grossincome.round(2))
      @loan.save
      # abort("#{@loan.info['annual_as_is_gross_income']}")

    end


    
    render json: @loan  
        
  end

end
