class EmailsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def index
    #email = Email.new
    #email.name = "Welcome email"
    #email.subject = "Welcome to IDV"
    #email.subject = "New FD Loan Submission"
    #email.content = "<p>full_name</p><p>Thank you for registration with us.</p>"
    #email.fixed_variable = "full_name"
    #email.save
    #Email.delete("55d32188dba1d66428000001")
    @emails = Email.all
   end

  def update_email
    email = Email.find(params[:id])
    email.content = params[:content]
    email.subject = params[:subject]
    email.save
    @emails = Email.all
    render partial: 'emails/emails'
  end

  def system_emails
    abort("#{params}")
  end

 def edit_email
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
    #abort("#{@detail.inspect}")
  end
  
  def received_emails
    uInfo = current_user
    @emails = LoanEmail.all(:to => uInfo.system_email, :from.ne => nil)
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
       uInfo = User.find_by_email(loan.email)
        if defined? uInfo.bucket_name && uInfo.bucket_name!= nil 
        @bucketName = uInfo.bucket_name
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
                @i=@i+1
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
    dbLoan.delete = 1
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
      filename = fileArray[params[:num].to_i]
      fname=fileArray.delete(filename)
      if !fname.blank?
        original = fname.join(",")
      end
      abort("#{original}")
      emailInfo.file_name = ""
      emailInfo.save

      render plain: 'delete'
  end
end
