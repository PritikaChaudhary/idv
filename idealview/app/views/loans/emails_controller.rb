class EmailsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def index
       # email = Email.new
       # email.name = "Deal for review"
       # email.subject = "Deal For You To Review"
       # email.content = "<div style='text-align:center; padding:5px'>There is a new loan for you to review at idealview.us.</div><BR><div style='margin-top:40px;'><h3><a href='loan_url'> loan_name </a></h3><div><b>Net Loan Amount Requested: </b> loan_amount </div><div><b>Value: </b> estimated_market_value </div><div><b>Desired Term Length: </b> desired_length </div></div><p style='margin-bottom:60px'>To view the details of this loan and to indicate interest visit this link: <a href='loan_url'>loan_name</a></p>"
       # email.fixed_variable = "loan_name, loan_amount, estimated_market_value, desired_length"
       # email.save
      #Email.delete("55d32188dba1d66428000001")
      @emails = Email.all(:name.ne => "Please Complete Loan")
      fd_forms = ["New FD Loan Submission", "Fund Loan", "Thanking you email for IDV loan.", "Thanking you email for fundingdatabase loans", "Incomplete Submissions"]
      shopping = ["Shop Loan", "Reject Shop Loan", "Lender Shop Loan", "Reminder", "Lender Accepted"]
      nt_using = ["Please Complete Loan"]
      nt_misc = ["New deal for review", "New summaries to consider", "Broker Login", "Request Access", "Sub Broker Login", "Broker Reset Password", "Thanking you email to subscribe plan", "Lender Login", "Loan Accepted", "Lender Accepted Email", "Deal for review"]
      @fd_emails = Email.all(:name=>fd_forms)
      @shopping_emails = Email.all(:name=>shopping)
      @misc_emails = Email.all(:name => nt_misc)
  end

  def update_email
    email = Email.find(params[:id])
    email.content = params[:content]
    email.subject = params[:subject]
    
    if email.name == "Shop Loan" || email.name == "New FD Loan Submission" || email.name == "Incomplete Submissions"
      email.to = params[:to]
    end
    
    email.save
    fd_forms = ["New FD Loan Submission", "Fund Loan", "Thanking you email for IDV loan.", "Thanking you email for fundingdatabase loans", "Incomplete Submissions"]
    shopping = ["Shop Loan", "Reject Shop Loan", "Lender Shop Loan", "Reminder", "Lender Accepted"]
    nt_misc = ["New deal for review", "New summaries to consider", "Broker Login", "Request Access", "Sub Broker Login", "Broker Reset Password", "Thanking you email to subscribe plan", "Lender Login", "Loan Accepted", "Lender Accepted Email", "Deal for review"]
    @fd_emails = Email.all(:name=>fd_forms)
    @shopping_emails = Email.all(:name=>shopping)
    @misc_emails = Email.all(:name => nt_misc)

    render partial: 'emails'
  end

  def system_emails
    abort("#{params}")
  end

 def edit_email
  @before = LoanEmail.find_by_id(params[:id])
  
  if @adminLogin!=true &&  @brokerLogin==true
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
      #abort("#{@broker_emails}")
      @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
      @loans = Loan.all(:delete.ne => 1, :archived.ne => true,:order => :id.desc)
    end
   

    @detail = LoanEmail.find_by_id(params[:id])
    @detail.read_status = 1
    @detail.save
    #abort("#{@detail.inspect}")
  end
  
  def received_emails
    # allEmails = LoanEmail.all
    # allEmails.each do |email|
    #   @detail = LoanEmail.find_by_id(email.id)
    #   @detail.read_status = 1
    #   @detail.save
    # end
    uInfo = current_user
    @emails = LoanEmail.all(:to => uInfo.system_email, :from.ne => nil, :order => :id.desc)
    @num = @emails.count
  end

   def loan_detail

    @lInfo = Loan.find_by_id(params[:loanId].to_i);
    render partial: 'emails/sidebar'
  end

  def custom_folders
    @folders = CustomFolder.all(:loan_id => params[:loanId])
    render partial: 'emails/sidebar'
  end
  
  def create_application
    loan_gurantor=params[:GurantorName]

    params.delete :action
    params.delete :GurantorName
    params.delete :controller     
   # abort("#{params.inspect}")
    params[:ContactType]="Borrower"
   # rsp= Infusionsoft.contact_add(params)
    @last_loan = Loan.last
    @new_id = @last_loan.id+1
    if params[:id].blank?
      dbLoan = Loan.new
      #abort("#{@infoUser.inspect}")
      dbLoan.added_by = params[:uId]
    else
      dbLoan = Loan.find_by_id(params[:id].to_i)
    end

    if params[:_LoanName].blank?
      dbLoan.name = 'Awesome Loan Name'
    else
      dbLoan.name=params[:_LoanName]
    end
    unless params[:Email].blank?
      dbLoan.email = params[:Email]
    end
    #params[:Id]=rsp
    params[:GurantorName]=loan_gurantor
    if params[:id].blank?
      dbLoan.id = @new_id
    end
    dbLoan.info=params
    dbLoan.delete=0
    dbLoan.save
      loan=Loan.find_by_id(dbLoan.id)

     if !loan.info['added_by'].blank?
        uInfo = User.find_by_id(loan.info['added_by'])
        if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 
        @bucketName = uInfo.bucket_name
        else
            @bucketName = S3_BUCKET_NAME
        end 
     else
      if !loan.email.blank?
       uInfo = User.find_by_email(loan.email)
        
        if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 
        @bucketName = uInfo.bucket_name
        else
            @bucketName = S3_BUCKET_NAME
        end 
      else
        @bucketName = S3_BUCKET_NAME
      end
     end
    unless params[:images].blank?
           
          
            
         params[:images].each do |img|
          if !img[1].blank?
             #File.rename "#{Rails.root}/filecontent/#{file_name[i]}", "#{Rails.root}/public/temp/#{file_name[i]}"
            contents =  File.read("#{Rails.root}/public/temp/#{img[1]}")
            # Make an object in your bucket for your upload
            loan_id =  dbLoan.id.to_s
            key_name = loan_id+'/'+img[1]
            obj = S3.put_object(
                     acl: "public-read",
                     bucket: @bucketName,
                     key: key_name,
                     body: contents
                     )
            image = Image.new
            image.loan_id =  dbLoan.id
            image.name = img[1]
            image.file_id =  key_name
            image.url =  "https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{dbLoan.id}/#{img[1]}"
            image.save
          end
        end
    end 
    
    unless params[:categories].blank?
        @i=0
        all_categories = [
                            'Borrower Info & Corporate Docs',
                            'Environmental',
                            'Property Inspections',
                            'Project',
                            'Title,Taxes & Insurance',
                            'Valuation',
                            'Other'
                          ]

        params[:categories].each do |cat|
          #File.rename "#{Rails.root}/filecontent/#{file_name[i]}", "#{Rails.root}/public/temp/#{file_name[i]}"
              
              check = all_categories.include? "#{cat[1]}"
              if  check==true
                
                if !cat.blank?
                  if cat[1]!="none"
                     val = params[:file_name]
                    contents =  File.read("#{Rails.root}/public/temp/#{val[@i.to_s]}")
                    loan_id =  dbLoan.id.to_s
                    key_name = loan_id+'/'+val[@i.to_s]
                    obj = S3.put_object(
                     acl: "public-read",
                     bucket: @bucketName,
                     key: key_name,
                     body: contents
                     )

                     doc = Document.new
                    doc.loan_id = dbLoan.id
                    doc.name = val[@i.to_s]
                    doc.category =  cat[1]
                    doc.save
                  end
                end
               
              else
                
                 if cat[1]!="none"
                     val = params[:file_name]
                    contents =  File.read("#{Rails.root}/public/temp/#{val[@i.to_s]}")
                    loan_id =  dbLoan.id.to_s
                    key_name = loan_id+'/'+val[@i.to_s]
                    obj = S3.put_object(
                     acl: "public-read",
                     bucket: @bucketName,
                     key: key_name,
                     body: contents
                     )

                   
                    doc = FolderFile.new
                    doc.loan_id = dbLoan.id
                    doc.name = val[@i.to_s]
                    doc.custom_folder_id =  cat[1]
                    doc.user_id =  params[:uId]
                    doc.save
                    #abort("#{doc.inspect}")
                 end
              end
           val=""
            @i=@i+1
        end
    end 

    

    if params[:id].blank?
      unless dbLoan.email.blank?
        LoanUrlMailer.thankyou_email(@new_id).deliver
      end
    end
    flash[:notice] = "Application is submitted successfully"  
    redirect_to :controller=>'loans', :action=> 'index' 
 end
  

  def add_loan
    loan_gurantor=params[:GurantorName]

    params.delete :action
    params.delete :GurantorName
    params.delete :controller     
   # abort("#{params.inspect}")
    params[:ContactType]="Borrower"
   # rsp= Infusionsoft.contact_add(params)
    @last_loan = Loan.last
    @new_id = @last_loan.id+1
    if params[:id].blank?
      dbLoan = Loan.new
      #abort("#{@infoUser.inspect}")
      dbLoan.added_by = params[:uId]
    else
      dbLoan = Loan.find_by_id(params[:id].to_i)
    end

    if params[:_LoanName].blank?
      dbLoan.name = 'Awesome Loan Name'
    else
      dbLoan.name=params[:_LoanName]
    end
    unless params[:Email].blank?
      dbLoan.email = params[:Email]
    end
    # dbLoan.delete = 1
    #params[:Id]=rsp
    params[:GurantorName]=loan_gurantor
    if params[:id].blank?
      dbLoan.id = @new_id
    end
    dbLoan.info=params
    dbLoan.save

    render plain: dbLoan.id
 end

 def all_categories
    @i = params[:num]
    @folder_name = ""
    @customs = CustomFolder.all(:loan_id => params[:id].to_i)
    render partial: 'emails/categories'
 end

 def custom_folder
     @i = params[:num]
    

    cstm = CustomFolder.new
    cstm.loan_id = params[:id]
    cstm.folder_name = params[:fname]
    cstm.user_id = params[:userId]
    cstm.save
    @folderName = cstm.id
    
    @customs = CustomFolder.all(:loan_id => params[:id].to_i)
    render partial: 'emails/categories'
 end

  
  def show_file
  	emailDetail = LoanEmail.find_by_id(params[:id])
  	fileArray = emailDetail.file_name.split(",")
  	filename = fileArray[params[:num].to_i]
   	mim = MIME::Types.type_for(filename).first.content_type
    filetype = mim
  	send_file "public/temp/#{filename}", :type => "#{filetype}"
  end


  def delete_file
      emailInfo = LoanEmail.find_by_id(params[:id])
      fileArray = emailInfo.file_name.split(",")
      fileArray.delete(params[:fname])
      if !fileArray.blank?
        original = fileArray.join(",")
      end
      info =  LoanEmail.find_by_id(params[:id])
      info.file_name = "#{original}"
      info.save
      render plain: 'delete'
  end

  def delete_emails
    uInfo = current_user
    ids=params[:moredata].split(",")
    ids.each do |number|
         LoanEmail.delete(number)
    end 
    @emails = LoanEmail.all(:to => uInfo.system_email, :from.ne => nil, :order => :id.desc)
    render partial: 'emails/allemails'
    flash.now[:notice] = "Emails deleted successfully"
  end

   def new_loan
    
    unless params[:id].blank?
      if params[:id]!=""
        loan = Loan.find_by_id(params[:id].to_i)
      else
        @last_loan = Loan.last
        @new_id = @last_loan.id+1
        loan = Loan.new
        if loan.info.blank?
           loan.info= params
        end
      end
    else
      @last_loan = Loan.last
      @new_id = @last_loan.id+1
      loan = Loan.new
      if loan.info.blank?
        loan.info= params
      end
    end
    
     unless params[:_LoanName].blank?
      loan.name=params[:_LoanName] 
     end
      
    unless params[:Email].blank?
      loan.email = params[:Email]
    end
    #params[:Id]=rsp
    if params[:id].blank?
     loan.id = @new_id
    end
    params.each do |key, value| 
      if key != "id"
        loan.info[key] = value
      end
     end
    loan.save

    render plain: loan.id
  end

  def new_collateral
      unless params[:collateral_id].blank?
      if params[:collateral_id]!=""
        collat = Collateral.find_by_id(params[:collateral_id])
      else
        collat = Collateral.new
      end
    else
      collat = Collateral.new
    end
    
     
    #params[:Id]=rsp
    params.each do |key, value| 
      if key == "address"
        collat.address = params[:address]
      elsif key == "postalcode"
        collat.postalcode = params[:postalcode] 
      elsif key == "estimated_value"
        collat.estimated_value = params[:estimated_value] 
      elsif key == "id"
        collat.loan_id = value.to_i
      elsif key == "amount_owed"
        collat.amount_owed = params[:amount_owed]
      elsif key == "asset_type"
        collat.asset_type = params[:asset_type]
      elsif key == "noi_ytd"
        collat.noi_ytd = params[:noi_ytd]
      elsif key == "noi_two_years_ago"
        collat.noi_two_years_ago = params[:noi_two_years_ago]
      elsif key == "noi_last_year"
        collat.noi_last_year = params[:noi_last_year]
      end
    end
    # abort("#{collat.inspect}")
    collat.save

    render plain: collat.id
  end

  def new_borrower
      unless params[:borrower_id].blank?
      if params[:borrower_id]!=""
        borwr = Borrower.find_by_id(params[:borrower_id])
      else
        borwr = Borrower.new
      end
    else
      borwr = Borrower.new
    end
    
     
    #params[:Id]=rsp
    params.each do |key, value| 
      if key == "personal_name"
        borwr.personal_name = params[:personal_name]
      elsif key == "personal_email"
        borwr.personal_email = params[:personal_email] 
      elsif key == "personal_postalcode"
        borwr.personal_postalcode = params[:personal_postalcode]
      elsif key == "personal_address"
        borwr.personal_address = params[:personal_address]
      elsif key == "id"
        borwr.loan_id = params[:id].to_i
      elsif key == "personal_gross"
        borwr.personal_gross = params[:personal_gross]
      elsif key == "personal_cashContribution"
        borwr.personal_cashContribution = params[:personal_cashContribution]
      elsif key == "bio"
        borwr.bio = params[:bio]
      end
    end
    borwr.save

    render plain: borwr.id
  end

  def add_file
    @bucketName = S3_BUCKET_NAME
    val = params[:file_name]


    contents =  File.read("#{Rails.root}/public/temp/#{val}")
    loan_id =  params[:loan_id].to_i
    key_name = "#{loan_id}/#{val}"
    obj = S3.put_object(
     acl: "public-read",
     bucket: @bucketName,
     key: key_name,
     body: contents
     )

    self_cat = "Borrower Info & Corporate Docs, Environmental, Property Inspections, Project, Title,Taxes & Insurance, Valuation, Other"
    if self_cat.include? "#{params[:category]}"
      # abort("yes")
      if params[:category].include? "Borrower Info"
        params[:category]="Borrower Info & Corporate Docs"
      end
      exist = Document.all(:loan_id =>loan_id.to_i, :name=>val, :category=>params[:category])
      if exist.blank?
        doc = Document.new
        doc.loan_id = loan_id.to_i
        doc.name = val
        doc.category =  params[:category]
        doc.url = "https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan_id}/#{val}"
        doc.save
      end
    else
      # abort("#{params[:category]} no")
      folder = FolderFile.new
      folder.custom_folder_id = params[:category].to_s
      folder.name = val
      folder.loan_id = loan_id.to_i
      folder.save
    end
    render plain: "done"
end

  def add_image
     @bucketName = S3_BUCKET_NAME
      val = params[:file_name]


      contents =  File.read("#{Rails.root}/public/temp/#{val}")
      loan_id =  params[:loan_id].to_i
      key_name = "#{loan_id}/#{val}"
      obj = S3.put_object(
       acl: "public-read",
       bucket: @bucketName,
       key: key_name,
       body: contents
       )

      images= Image.new
      images.loan_id = loan_id.to_i
      images.file_id = key_name
      images.name = val
      images.url = "https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan_id}/#{val}"
      images.save

      render plain: "done"
  end

  def add_borrower
    @loan_id = params[:loanId].to_i
    unless params[:borrower_id].blank?
      @brwr = Borrower.find_by_id("#{params[:borrower_id]}")
    end

    render partial: 'emails/add_borrowers'
  end

  def add_collateral
    @loan_id = params[:loanId].to_i

    unless params[:collateral_id].blank?
      @collateral = Collateral.find_by_id("#{params[:collateral_id]}")
    end

    render partial: 'emails/add_collateral'
  end

  def all_borrowers
    unless params[:search].blank?
      loan_id = params[:loanId].to_i
      all = Borrower.all(:loan_id => loan_id)
      ids = Array.new
      search_text = params[:search].downcase
      all.each do |borrower|
        persnal = borrower.personal_name.downcase
        if persnal.include? "#{search_text}"
          ids << borrower.id
        end
      end
      @borrowers = Borrower.all(:id => ids)
    else
      loan_id = params[:loanId].to_i
      @borrowers = Borrower.all(:loan_id => loan_id)
    end
    render partial: 'emails/all_borrowers'
  end

  def all_collaterals
    unless params[:search].blank?
      loan_id = params[:loanId].to_i
      all = Collateral.all(:loan_id => loan_id)
      ids = Array.new
      search_text = params[:search].downcase
      all.each do |collateral|
        asset_type = collateral.asset_type.downcase
        if asset_type.include? "#{search_text}"
          ids << collateral.id
        end
      end
      @collaterals = Collateral.all(:id => ids)
    else
      loan_id = params[:loanId].to_i
      @collaterals = Collateral.all(:loan_id => loan_id)
    end
    render partial: 'emails/all_collaterals'
  end

end
