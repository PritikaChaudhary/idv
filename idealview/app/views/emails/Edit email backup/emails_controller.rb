class EmailsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def index
       # email = Email.new
       # email.name = "Please Complete Loan"
       # email.subject = "Please Complete Your Loan"
       # email.content = "<p>Your loan information is incomplete. Please click on the link to complete your loan fd_link."
       # email.fixed_variable = "fd_link"
       # email.save
      #Email.delete("55d32188dba1d66428000001")
      @emails = Email.all
  end

  def update_email
    email = Email.find(params[:id])
    email.content = params[:content]
    email.subject = params[:subject]
    
    if email.name == "Shop Loan" || email.name == "New FD Loan Submission" || email.name == "Incomplete Submissions"
      email.to = params[:to]
    end
    
    email.save
    @emails = Email.all
    render partial: 'emails/emails'
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
      elsif key == "estimated_value"
        collat.estimated_value = params[:estimated_value] 
      elsif key == "amount_owed"
        collat.amount_owed = params[:amount_owed] 
      elsif key == "id"
        collat.loan_id = value.to_i
      elsif key == "mortgage_status"
        collat.mortgage_status = params[:mortgage_status]
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
      elsif key == "personal_monthly_income"
        borwr.personal_monthly_income = params[:personal_monthly_income]
      elsif key == "id"
        borwr.loan_id = params[:id].to_i
      elsif key == "time_in_business"
        borwr.time_in_business = params[:time_in_business]
      elsif key == "borrower_type"
        borwr.borrower_type = params[:borrower_type]
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

end
