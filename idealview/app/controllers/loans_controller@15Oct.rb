class LoansController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'

  skip_before_action :verify_authenticity_token, :only => :post_new_loan
  before_action :verify_custom_authenticity_token, :only => :post_new_loan



 def index
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
         end#
        end
      end
      @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
      @loans = Loan.all(:delete.ne => 1, :archived.ne => true,:order => :id.desc)
    end
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
    end
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

    # @loans.each do |loan|
        # dbLoan = Loan.find_by_id(loan['Id'])
        # if dbLoan.blank?
          # dbLoan = Loan.new()
          # dbLoan.id = loan['Id']
          # dbLoan.save
        # end
        # dbLoan.images.each do |temp|
          # if temp.url.blank?
            # temp.delete
          # end
        # end
        # @images = dbLoan.get_images
#      
    # end 
    # temp = @loans.count 
 
  end
  
  def show
    @terms = TermCondition.find_by_type("shop_loans")
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
   
      @images = @loan.images
      @documents = @loan.get_docs
      @loan.save()
    
    end
   @folders = CustomFolder.all(:loan_id => @loan.id.to_i)
   @funds = @loan.use_of_fund 
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
     file_name=file_io.original_filename
     
     File.open(Rails.root.join('public', 'temp', file_io.original_filename), 'wb') do |file|
        
      contents = file_io.read
      # Make an object in your bucket for your upload
      key_name = loan.id.to_s+'/'+file_name
      obj = S3.put_object(
               acl: "public-read",
               bucket: @bucketName,
               key: key_name,
               body: contents
               )
          
          if obj.last_page?
            ext =  file_name.split('.').last.downcase 
            check = Image.find_by_name(file_name)
            if check && check.loan_id == loan.id
              image = check
            else
              image = Image.new(:loan_id=>loan._id, :file_id=>key_name, :name=>file_name, :url=>"https://s3-us-west-2.amazonaws.com/#{@bucketName}/#{loan.id}/#{file_name}");
            end
            image.featured = false
            image.save()
            output['files'].push({:name=>file_name, :success=>'Upload was successful!'})
          end    
       
     end 
   end
    render json: output
    return
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
      @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
      
       @loans = Loan.all(:delete.ne => 1, :archived.ne => true, :order => :id.desc)
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
    id = Base64.decode64(Base64.decode64(params[:id])) 
    loan_url = Loan.find_by_id(id.to_i)

    if loan_url
      @loan = loan_url
    end

    time = @loan.url_time
    next_month = Time.utc(time.year, time.month+1, time.day) 
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
      @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
      
       @loans = Loan.all(:delete.ne => 1, :archived.ne => true, :order => :id.desc)
    end
    
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
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
      @loans = Loan.all(:email =>@broker_emails, :delete.ne => 1, :archived.ne => true, :order => :sort_id.asc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10)
      @loans = Loan.all(:delete.ne => 1, :archived.ne => true, :order => :sort_id.asc)
    end
    
    @shopLoans = ShopLoan.all(:user_id => current_user.id.to_s)
    @shop_ids = Array.new
    @shopLoans.each do |sloan|
      @shop_ids << sloan.loan_id
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
  #abort(params[:content]);
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
  doc = Document.find(@doc_id)
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
    #abort("#{brokerInfo.inspect}")
    #abort("#{@names.inspect}")
    #Infusionsoft.contact_add({:FirstName => 'Amy', :LastName => 'Virk', :Email => 'amyvirk@gmail.com'})
  
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

    dbLoan = Loan.new()
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
    dbLoan.id = @new_id
    dbLoan.info=params
    dbLoan.save
    amnts = params[:amount]
    uses = params[:use]
    if !amnts.blank?
      num = 0
      amnts.each do |amnt|
        if amnt!=""
          fnd = UseOfFund.new
          fnd.use = uses[num]
          fnd.amount = amnt
          fnd.loan_id = dbLoan.id
          fnd.save
          num = num+1
        end
      end
    end
    unless dbLoan.email.blank?
      LoanUrlMailer.thankyou_email(@new_id).deliver
    end
    flash[:notice] = "Application is submitted successfully"  
    redirect_to action: 'index'
 end  
 
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
    @pdfs=Pdf.all(:conditions=>["name != ''"])
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
   if params['sorting'] == "recent"
      @loans_record = Loan.find(ids)
      if @loans_record.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans=@loans_record.reverse { |k| k['id'] }
      end
      flash.now[:notice] = "Searching by recent Loans"
      render partial: 'loans/all_loans'
   else
      @loans_record = Loan.find(ids)
      if @loans_record.blank?
        @loans = Array.new
        @empty =  "No Loan Found."
      else
        @loans=@loans_record.sort_by { |k| k['sort_id'] }
      end
      flash.now[:notice] = "Searching by priority"
      render partial: 'loans/sort_loans'
   end
   ########################################### Check Sorting End ##############################################
  end

  def post_new_loan
    unless params.blank?
      params.delete :action
      params.delete :_wp_http_referer
      params.delete :controller
      @last_loan = Loan.last
      @new_id = @last_loan.id+1
      time = Time.new
      unless params[:nvid].blank?
        id = params[:nvid].to_i
        dbloan=Loan.find_by_id(id)
      else
        dbloan=Loan.new
      end

      if params[:nvid].blank?
        dbloan.info= params
        dbloan.email = params[:Email]
        dbloan.created_date = time.strftime("%Y-%m-%d %H:%M:% S")
        dbloan.id = @new_id
        dbloan.incomplete = 1
      else
        @info_arr = dbloan.info
        @innfo_arr=@info_arr.merge(params)
        dbloan.info = @innfo_arr
      end
      unless params[:_LoanName].blank?
        dbloan.name= params[:_LoanName]
      end
      dbloan.stepping = params[:stepping]
      if params[:stepping] == 18 
        dbloan.completed = 1
        dbloan.incomplete = 0
      end

      dbloan.save
      unless  params[:Email].blank?
         enc = Base64.encode64(dbloan.id.to_s)
         enc2 = Base64.encode64(enc)
         dbloan.doc_url = enc2
         dbloan.url_time = Time.now.getutc
          dbloan.save
         LoanUrlMailer.thankyou_fdLoan(dbloan.id).deliver
      end
      if  params[:stepping] == "18"
        LoanUrlMailer.complete_loan(params[:nvid]).deliver
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
    folder.user_id = params[:user_id]
    folder.save

    @folders = CustomFolder.all(:loan_id => params[:loan_id].to_i, :delete.ne=>1, :hide.ne=>1)
    render partial: 'loans/all_folders'
  end

  def verify_custom_authenticity_token
  # checks whether the request comes from a trusted source
  end

  def detail
     #id = Base64.decode64(Base64.decode64(params[:id]))
    loan_url = LoanUrl.find_by_url(params[:id])

    if loan_url
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
      copyLoan.user_id = @infoUser.id
      copyLoan.loan_id = detail.id
      copyLoan.shop_date = Time.now.getutc
      #copyLoan.featured = detail.id
      copyLoan.save

      funds = detail.use_of_fund
      funds.each do |fund|
        fnd = UseFund.new
        fnd.use = fund.use
        fnd.amount = fund.amount
        fnd.copy_loan_id = "#{copyLoan.id}"
        fnd.save
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
      copyLoan.loan_id = detail.id
      copyLoan.shop_date = Time.now.getutc
      #copyLoan.featured = detail.id
      copyLoan.save


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
      redirect_to '/'
    end
    #abort("#{@bucketName}") 
    #bucket = S3.create_bucket(bucket: 'testbusketxyz')
    
    @loan = CopyLoan.find_by_id(params[:id])
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
    start_time=Time.now

    if !@lenders.blank?

      serial=0
      @lenders.each do |lndr|
        # abort("#{lndr.inspect}")
        lender = LoanLender.find_by_id("#{lndr.id}")
        if lender.status != "decline"
          num = lndr.hours.to_i*60*60
          end_time = Time.now + num
          serial = serial+1
          lender.send_date = start_time
          lender.start_time = start_time
          lender.end_time = end_time
          lender.priority = serial
          if serial==1
              lender.status = "active"
               allreminders = Reminder.all(:copy_loan_id => "#{params[:loan_id]}" )
               if !allreminders.blank?
                allreminders.each do |remind|
                    rm = Reminder.find_by_id(remind.id)
                    rm.status = 0
                    rm.save
                end
              end
              # LoanUrlMailer.lender_shop_loan(lender.id).deliver
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
     @alllenders = LoanLender.all(:copy_loan_id => params[:loan_id], :order => :priority.asc)
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
    
    
    if !@allLenders.blank?
      i=1
      @allLenders.each do |lender|
        linfo = LoanLender.find_by_id("#{lender.id}")
        linfo.hours = params[:hours]
        linfo.priority=i
        linfo.saved = 1
        linfo.save
        i = i+1
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
    uses = params[:use]
    amnt = params[:amount]
    idx = params[:id]
    num = 0
    uses.each do |use|
      if idx[num].blank?
        # abort("no----#{idx[num]}")
        fund = UseOfFund.new
      else
         # abort("yes----#{idx[num]}")
        fund = UseOfFund.find_by_id(idx[num])
      end
      fund.use = use
      fund.amount = amnt[num]
      fund.loan_id=params[:loan_id]
      fund.save
      num = num+1
    end
    @funds = UseOfFund.all(:loan_id => params[:loan_id].to_i)

    render partial: 'fund_info'
  end

end
