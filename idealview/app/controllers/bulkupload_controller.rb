class BulkuploadController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'


  
 def index

    if current_user.blank?
      redirect_to "/users/sign_in"
    else

     @terms = TermCondition.find_by_type("shop_loans")
     @check_syncloan = SyncLoan.find_by_user_id("#{current_user.id}")
      @syncing = 0
      # abort("#{check_syncloan.inspect}")
     unless @check_syncloan.blank?
       if @check_syncloan.status == 0 
        @syncing = 1
       end
     end
     # abort("#{current_user.dropbox.inspect}")
     # loan = Loan.find_by_id(4146)
     # abort("#{loan.inspect}")
      #################### Check Login #######################
        # abort("#{current_user.inspect}")
        roles=current_user.roles

        @user_info = User.find_by_id("#{current_user.id}")
        @dropbox = @user_info.dropbox
        # abort("#{@dropbox}")
        # uInfo.cpc_username = ""
        # uInfo.save
        
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

        # abort("#{current_user.inspect}")
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
          # @loan = Loan.find_by_id(4089)
          # abort("#{@loan.inspect}")
          @total_loans = Loan.count(:email =>@broker_emails, :delete_broker.ne => 1, :delete.ne => 1, :archived.ne => true)
          @loans = Loan.paginate(:email =>@broker_emails, :delete.ne => 1, :delete_broker.ne => 1, :archived.ne => true, :per_page => 10, :page => params[:page], :total_entries => @total_loans, :order => :id.desc) 
          # abort("#{@loans.inspect}")
        else
          #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
          @total_loans = Loan.count(:delete.ne => 1, :delete_admin.ne => 1, :archived.ne => true) 
          @loans = Loan.paginate(:delete.ne => 1, :delete_admin.ne => 1, :archived.ne => true, :per_page => 10, :page => params[:page], :total_entries => @total_loans, :order => :id.desc)
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

        @groups = ShopGroup.all

         unless current_user.blank?
         ##################### Memmory Size ######################

        docs = Document.where(:user_id=>"#{current_user.id}").fields(:file_size).all
        file_size = 0
        
        docs.each do |doc|
          unless doc.file_size.blank?
            file_size += doc.file_size
          end
        end

        other_docs = FolderFile.where(:user_id=>"#{current_user.id}").fields(:file_size).all
        other_docs.each do |other_doc|
          unless other_doc.file_size.blank?
            file_size += other_doc.file_size
          end
        end

        loan_images = Image.where(:user_id=>"#{current_user.id}").fields(:file_size).all
        loan_images.each do |loan_image|
          unless loan_image.file_size.blank?
            file_size += loan_image.file_size
          end
        end

        # abort("Documents #{docs.inspect} <br> #{other_docs.inspect} <br> #{loan_images.inspect}")
        @bucket_size = file_size

        ##################### Memmory Size End ##################
        

        ################# Bucket Size ###########################
        
        @bucket_mb = @bucket_size
        if @adminLogin != true
          if !@infoBroker.blank? 
              
            munit = current_user.max_storage.gsub(/\d+/,'')
            mint = current_user.max_storage.to_i


            if munit == "MB"
              unless current_user.expand_memory.blank?
                @max_size = mint+10240 
              else
                @max_size = mint
              end
            elsif munit == "GB"
              unless current_user.expand_memory.blank?
                mint = mint*1024
                @max_size = mint+10240 
              else
                mint = mint*1024
                @max_size = mint.to_i
              end
            end
               

            
            if @bucket_mb < @max_size
              @fileUpload = "true"
              @size_left = @max_size.to_i - @bucket_mb.to_f
              @size_left_kb = @size_left * 1024 *1024
            else
              @fileUpload = "false"
            end
          end
        else
          @fileUpload = "true"
        end

           
          
            

        if !@adminLogin.blank?
          @fileUpload = "true"
        end

      

        ################# Bucket Size End #########################

        ################ Max Upload ###############################

          if @adminLogin.blank?
            unless current_user.max_upload.blank?
              if current_user.max_upload == "No File Cap"
                @max_upload = "No File Cap"
              else
                munit = current_user.max_upload.gsub(/\d+/,'')
                mint = current_user.max_upload.to_i 
                if munit == "GB"
                  @max_upload = mint.to_i * 1024 * 1024 * 1024
                else
                  @max_upload = mint.to_i * 1024 * 1024
                end
              end
            end
          end

        ################ End Max Upload ###############################
        end
    end
    
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
      @total_loans = Loan.count(:email =>@broker_emails, :delete_broker.ne =>1, :delete.ne => 1, :archived.ne => true)
      @loans = Loan.paginate(:email =>@broker_emails, :delete_broker.ne =>1, :delete.ne => 1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10, :page => params[:page])
       @total_loans = Loan.count(:delete.ne => 1, :delete_admin.ne =>1, :archived.ne => true);

       @loans = Loan.paginate(:delete.ne => 1, :delete_admin.ne =>1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc)
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
    
    render partial: 'all_loans'
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
      @lns = Loan.all(:email =>@broker_emails, :delete_broker.ne=>1, :delete.ne => 1, :archived.ne => true, :order => :sort_id.asc) 
    else
      #@loans = Loan.paginate(:delete.ne => 1, :archived.ne => true, :order => :id.desc, :per_page => 10)
      @lns = Loan.all(:delete.ne => 1,:delete_admin.ne=>1 , :archived.ne => true, :order => :sort_id.asc)
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
      
    end
    render partial: 'all_loans'
   end

###################### Sync All Folders ################################

  def import_from_dropbox
    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    client = DropboxClient.new(access_token)
    info = client.account_info().inspect
    # abort("#{info.inspect}")
    not_exist = 0
    begin
      root_metadata = client.metadata('/IDV')
      rescue Exception => exc
      if exc.message
        not_exist = 1
      end
    end

    if not_exist != 1
      if root_metadata['is_deleted'] == true
        not_exist = 1
      end
    end
    
    if not_exist != 1
      

      all_folders = root_metadata['contents']
      
      all_folders.each do |folder|
        name = folder['path'].gsub('/IDV/', '')
        
        
          if folder['is_dir'] == true
            check = Loan.find_by_dropbox_name("#{name}")
            if check.blank?
              @last_loan = Loan.last
              @new_id = @last_loan.id+1
              dbLoan = Loan.new()
              dbLoan.id = @new_id.to_i
              dbLoan.name = folder['path'].gsub('/IDV/', '')
              dbLoan.dropbox_name = folder['path'].gsub('/IDV/', '')
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
              
              loanInfo = Hash.new
              loanInfo['name'] = folder['path'].gsub('/IDV/', '')
              dbLoan.email=current_user.email
              dbLoan.info = loanInfo
              time_nw = Time.now
              dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
              dbLoan.created_at=Time.now
            dbLoan.save
            else
              @loanInfo = Loan.find_by_dropbox_name("#{name}")
              @new_id = @loanInfo.id 
            end

            ############## Loan Data ##################
            loan_data = client.metadata("#{folder['path']}")
            # abort("#{loan_data.inspect }")
            unless loan_data['contents'].blank?
              loan_data['contents'].each do |ldata|
                
                 begin
                    parent_path = folder['path'].downcase
                    rescue Exception => exc
                    if exc.message
                      abort("#{folder.inspect}")
                    end
                  end
                ############## Loan Images ##############
                path = "#{parent_path}/images"
                if ldata['path'].downcase == path
                  loan_images = client.metadata("#{ldata['path']}")
                  loan_images['contents'].each do |limages|
                    if limages['is_dir'] == false 

                      file_path = "#{limages['path']}"
                      file_array = file_path.split("/")
                        now_time = Time.now.strftime("%m%d%y%H%M%S")
                        file_name = "#{now_time}#{file_array.last}"
                        file_name = file_name.gsub(" ","_")
                        checkImage = Image.all(:dropbox_name => "#{file_array.last}", :loan_id => @new_id.to_i)

                        if checkImage.blank?
                          contents, metadata = client.get_file_and_metadata("#{file_path}")
                          require 'open-uri'
                          uId = current_user.id
                          File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
                            file.write contents
                            ############# Google Cloud Storage ###########
                            
                              structure = "#{current_user.id}/#{@new_id}/#{file_name}"

                              store_data = StorageBucket.files.new(
                                key: "#{structure}",
                                body: contents,
                                public: true
                              );
                              
                              store_data.save
                           
                            ############# Google Cloud Storage ###########
                            up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
                            file_kb = up_size.to_f/1024
                            @file_mb = file_kb.to_f/1024
                            image = Image.new(:loan_id=>@new_id.to_i, :file_size=>@file_mb, :user_id=>"#{current_user.id}", :from=>"google", :file_id=>structure, :name=>"#{file_name}", :dropbox_name=>"#{file_array.last}", :url=>"#{store_data.public_url}");
                            image.featured = false
                            image.save()
                        end
                      end
                    end
                  end
                end
                ############## End Loan Images ##############

                ############# Loan Documents ############
                path = "#{parent_path}/documents"
                if ldata['path'].downcase == path
                  
                  loan_documents = client.metadata("#{ldata['path']}")
                  unless loan_documents['contents'].blank?
                    lfolder = CustomFolder.first(:loan_id => @new_id.to_i, :folder_name => "Dropbox")

                    if lfolder.blank?
                      lfolder = CustomFolder.new
                      lfolder.folder_name = "Dropbox"
                      lfolder.dropbox_name = "Dropbox"
                      lfolder.loan_id = @new_id.to_i
                      unless current_user.id.blank?
                        lfolder.user_id = "#{current_user.id}"
                      end 
                      lfolder.save
                    end
                    # abort("#{lfolder.id}")
                    lfolder_id = lfolder.id
                    loan_documents['contents'].each do |document|
                      if document['is_dir'] == true
                        
                      else
                        

                          file_path = "#{document['path']}"
                        file_array = file_path.split("/")
                          now_time = Time.now.strftime("%m%d%y%H%M%S")
                          file_name = "#{now_time}#{file_array.last}"
                          file_name = file_name.gsub(" ","_")
                          if_doc = FolderFile.all(:custom_folder_id => "#{lfolder_id}", :dropbox_name => "#{file_array.last}")
                          
                          if if_doc.blank?
                            contents, metadata = client.get_file_and_metadata("#{file_path}")
                            require 'open-uri'
                            uId = current_user.id
                            File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
                              file.write contents
                              ############# Google Cloud Storage ###########
                                
                                structure = "#{current_user.id}/#{@new_id}/#{file_name}"
                                store_data = StorageBucket.files.new(
                                  key: "#{structure}",
                                  body: contents,
                                  public: true
                                );
                                # abort("#{store_data.inspect}")
                                store_data.save
                              storage_url = store_data.public_url 
                              ############# Google Cloud Storage ###########
                              up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
                              file_kb = up_size.to_f/1024
                              @file_mb = file_kb.to_f/1024

                              doc = FolderFile.new
                                  doc.loan_id = @new_id.to_i
                                  doc.name = "#{file_name}"
                                  unless current_user.blank?
                                    doc.user_id = current_user.id
                                  else
                                    doc.user_id = "outsider"
                                  end
                                  doc.custom_folder_id = "#{lfolder_id}"
                                  doc.url = "#{storage_url}"
                                  doc.dropbox_name = "#{file_array.last}"
                                  doc.file_size = @file_mb
                                  doc.from = "google"
                                  doc.save()
                                  # abort("#{doc.inspect}")
                                  File.delete("#{Rails.root}/public/temp/#{file_name}")
                          end
                        end


                      end
                    end
                  end

                end
                ############# End Loan Documents ############
              end
            end
            ############## End Loan Data ##################
          end
        
      end
      recent('desc')
  else
    render text: "error"
  end
    # file = open('working-draft.txt')
    # response = client.put_file('/magnum-opus.txt', file)
    # puts "uploaded:", response.inspect
  end

  #################### End Sync All folders ##########################

  def download_dropbox_document
    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    client = DropboxClient.new(access_token)
    info = client.account_info().inspect
    # file = open('working-draft.txt')
    # response = client.put_file('/magnum-opus.txt', file)
    # puts "uploaded:", response.inspect

    file_path = "#{params[:path]}"
    file_array = file_path.split("/")
    file_name = Time.now.strftime("%m%d%y%H%M%S")+file_array.last
    file_name = file_name.gsub(" ","_")
    not_find = 0
    begin
      contents, metadata = client.get_file_and_metadata("#{file_path}")
      rescue Exception => exc
      if exc.message
        not_find = 1
      end
    end
    if not_find!=1 
      require 'open-uri'
      uId = current_user.id
      File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
        file.write contents
        ############# Google Cloud Storage ###########
        
          structure = "#{current_user.id}/#{params[:loan_id]}/#{file_name}"
          store_data = StorageBucket.files.new(
            key: "#{structure}",
            body: contents,
            public: true
          );
          
          store_data.save
        storage_url = store_data.public_url
        ############# Google Cloud Storage ###########
        up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
        file_kb = up_size.to_f/1024
        @file_mb = file_kb.to_f/1024
        doc = FolderFile.new
        doc.loan_id = params[:loan_id].to_i
        doc.name = "#{file_name}"
        unless current_user.blank?
          doc.user_id = current_user.id
        else
          doc.user_id = "outsider"
        end
        doc.custom_folder_id = "#{params[:val]}"
        doc.url = "#{storage_url}"
        doc.file_size = @file_mb
        doc.from = "google"
        doc.save()

      end
    
       render text: "done"
    else
       render text: "error"
    end
  end

  def download_dropbox_cdocument
    # abort("dsdf")
    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    client = DropboxClient.new(access_token)
    info = client.account_info().inspect

    # file = open('working-draft.txt')
    # response = client.put_file('/magnum-opus.txt', file)
    # puts "uploaded:", response.inspect

    file_path = "#{params[:path]}"
    file_array = file_path.split("/")
    file_name = Time.now.strftime("%m%d%y%H%M%S")+file_array.last
    file_name = file_name.gsub(" ","_")
    not_find = 0
    begin
      contents, metadata = client.get_file_and_metadata("#{file_path}")
      
      rescue Exception => exc
      if exc.message
        not_find = 1
      end
    end
    # abort("#{not_find}")
    if not_find!=1
      require 'open-uri'
      uId = current_user.id
      File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
        file.write contents
        ############# Google Cloud Storage ###########
        
        structure = "#{current_user.id}/#{params[:loan_id]}/#{file_name}"
        store_data = StorageBucket.files.new(
          key: "#{structure}",
          body: contents,
          public: true
        );
        
        store_data.save
      storage_url = store_data.public_url

        ############# Google Cloud Storage ###########
        up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
        file_kb = up_size.to_f/1024
        @file_mb = file_kb.to_f/1024
        doc = Document.new
        doc.loan_id = params[:loan_id].to_i
        doc.user_id = "#{current_user.id}"
        doc.from = "google"
        doc.name = "#{file_name}"

        if params[:val] == "Borrower Info "
          doc.category = "Borrower Info & Corporate Docs"
        elsif params[:val] == "Title,Taxes "
          doc.category = "Title,Taxes & Insurance"  
        else
          doc.category = params[:val]
        end
        
        doc.file_size = @file_mb
        doc.url = "#{storage_url}"
        doc.save()
      end 
        
      render text: "done"
  else
      render text: "error"
  end
  end

  def create_folder
    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    client = DropboxClient.new(access_token)
    info = client.account_info().inspect

    response = client.file_create_folder("/IDV")
    render text: "done"

  end

  def check_folder
    # abort("dsdf")
    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    

    headers = {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json" }
    uri = URI.parse("https://api.dropboxapi.com/2/files/get_metadata");
     
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    
    request = Net::HTTP::Post.new(uri.request_uri)
    data = {"path" => "/IDV"}
    jdata = data.to_json
    response = http.post(uri.path, jdata, headers)
    rsp = response.body
    objArray = JSON.parse(rsp)
    # abort("#{objArray.inspect}")
    if objArray['error_summary']
      render text: "error"
    else
      render text: "done"
    end
  end

  ####################### List Folders ########################
  
  def list_folders
    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    
    # abort("#{uInfo.token}")
    headers = {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json" }
    uri = URI.parse("https://api.dropboxapi.com/2/files/list_folder");
     
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    
    request = Net::HTTP::Post.new(uri.request_uri)
    data = {"path" => "/IDV"}
    jdata = data.to_json
    response = http.post(uri.path, jdata, headers)
    rsp = response.body
    objArray = JSON.parse(rsp)
    # abort("#{objArray['entries']}")
    not_exist = 0
    if objArray['error_summary']
      not_exist = 1
    end
    
    if not_exist!=1
      all_folders = objArray['entries']
      folder_names = Array.new
      unless all_folders.blank?
        all_folders.each do |folder|

            name = folder['name']
            folder_names << name
          
        end
      end
      @all_folders = folder_names
      if @all_folders.blank?
        render text: "empty"
      else
        render partial: "folders_list"
      end
      
    end



  end


  ####################### End List Folders ########################

  ####################### Sync Folders ############################
  def sync_folders
    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    @headers = {"Authorization" => "Bearer #{uInfo.token}", "Content-Type" => "application/json" }
    all_folders = params[:folders].split(',')
    
    all_folders.each do |afolder|
            check = Loan.first(:dropbox_name => "#{afolder}", :created_by_email=>"#{current_user.email}")
            
            if check.blank?
              @last_loan = Loan.last
              @new_id = @last_loan.id+1
              dbLoan = Loan.new()
              dbLoan.id = @new_id.to_i
              dbLoan.name = "#{afolder}"
              dbLoan.dropbox_name = "#{afolder}"
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
              
              loanInfo = Hash.new
              loanInfo['name'] = "#{afolder}"
              loanInfo['_LoanName'] = "#{afolder}"
              dbLoan.email=current_user.email
              dbLoan.info = loanInfo
              time_nw = Time.now
              dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
              dbLoan.created_at=Time.now
              dbLoan.save
            else
              @loanInfo =  Loan.first(:dropbox_name => "#{afolder}", :created_by_email=>"#{current_user.email}")
              @new_id = @loanInfo.id 
              if @brokerLogin == true
                @loanInfo.delete_broker = 0
              end
              if @adminLogin == true
                @loanInfo.delete_admin = 0
              end
              @loanInfo.save
              # abort("#{@loanInfo.inspect}")
            end

            ############## Loan Data ##################
            # loan_data = client.metadata("/IDV/#{afolder}")
           
            uri = URI.parse("https://api.dropboxapi.com/2/files/list_folder");
     
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
            
            request = Net::HTTP::Post.new(uri.request_uri)
            data = {"path" => "/IDV/#{afolder}"}
            jdata = data.to_json
            response = http.post(uri.path, jdata, @headers)
            rsp = response.body
            objArray = JSON.parse(rsp)



            # abort("#{loan_data.inspect }")
            unless objArray['entries'].blank?
              objArray['entries'].each do |ldata|
                  begin
                    parent_path = "/IDV/#{afolder}"
                    rescue Exception => exc
                    if exc.message
                      abort("#{folder.inspect}")
                    end
                  end
                ############## Loan Images ##############
                path = "#{parent_path}/images"
                if ldata['path_display'] == path
                    
                    # loan_images = client.metadata("#{ldata['path_display']}")
                  ################### Fetch Data ##########################
                    uri = URI.parse("https://api.dropboxapi.com/2/files/list_folder");
     
                    http = Net::HTTP.new(uri.host, uri.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                    
                    request = Net::HTTP::Post.new(uri.request_uri)
                    data = {"path" => "#{ldata['path_display']}"}
                    jdata = data.to_json
                    response = http.post(uri.path, jdata, @headers)
                    rsp = response.body
                    loan_images = JSON.parse(rsp)

                  ################### End Fetch Data ##########################  
                  loan_images['entries'].each do |limages|
                    if limages['.tag'] == "file" 

                      file_path = "#{limages['path_display']}"
                      now_time = Time.now.strftime("%m%d%y%H%M%S")
                      file_name = "#{now_time}#{limages['name']}"
                        file_name = file_name.gsub(" ","_")
                        checkImage = Image.all(:dropbox_name => "#{limages['name']}", :loan_id => @new_id.to_i)

                        if checkImage.blank?
                          # contents, metadata = client.get_file_and_metadata("#{file_path}")
                          
                          ################### Fetch Data ##########################
                            uri = URI.parse("https://api.dropboxapi.com/2/files/get_temporary_link");
             
                            http = Net::HTTP.new(uri.host, uri.port)
                            http.use_ssl = true
                            http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                            
                            request = Net::HTTP::Post.new(uri.request_uri)
                            data = {"path" => "#{limages['path_display']}"}
                            jdata = data.to_json
                            response = http.post(uri.path, jdata, @headers)
                            rsp = response.body
                            img_data = JSON.parse(rsp)
                            contents = open("#{img_data['link']}").read
                          ################### End Fetch Data ##########################  


                          require 'open-uri'
                          uId = current_user.id
                          File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
                            file.write contents
                            ############# Google Cloud Storage ###########
                            
                              structure = "#{current_user.id}/#{@new_id}/#{file_name}"

                              store_data = StorageBucket.files.new(
                                key: "#{structure}",
                                body: contents,
                                public: true
                              );
                              
                              store_data.save
                           
                            ############# Google Cloud Storage ###########
                            up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
                            file_kb = up_size.to_f/1024
                            @file_mb = file_kb.to_f/1024
                            image = Image.new(:loan_id=>@new_id.to_i, :file_size=>@file_mb, :user_id=>"#{current_user.id}", :from=>"google", :file_id=>structure, :name=>"#{file_name}", :dropbox_name=>"#{limages['name']}", :url=>"#{store_data.public_url}");
                            image.featured = false
                            image.save()
                        end
                      end
                    end
                  end
                end
                ############## End Loan Images ##############

                ############# Loan Documents ############
                path = "#{parent_path}/documents"
                if ldata['path_display'] == path
                  
                  ################### Fetch Data ##########################
                    uri = URI.parse("https://api.dropboxapi.com/2/files/list_folder");
     
                    http = Net::HTTP.new(uri.host, uri.port)
                    http.use_ssl = true
                    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                    
                    request = Net::HTTP::Post.new(uri.request_uri)
                    data = {"path" => "#{ldata['path_display']}"}
                    jdata = data.to_json
                    response = http.post(uri.path, jdata, @headers)
                    rsp = response.body
                    loan_documents = JSON.parse(rsp)

                  ################### End Fetch Data ##########################  


                  unless loan_documents['entries'].blank?
                    lfolder = CustomFolder.first(:loan_id => @new_id.to_i, :folder_name => "Dropbox")

                    if lfolder.blank?
                      lfolder = CustomFolder.new
                      lfolder.folder_name = "Dropbox"
                      lfolder.dropbox_name = "Dropbox"
                      lfolder.loan_id = @new_id.to_i
                      unless current_user.id.blank?
                        lfolder.user_id = "#{current_user.id}"
                      end 
                      lfolder.save
                    end
                    # abort("#{lfolder.id}")
                    lfolder_id = lfolder.id
                    loan_documents['entries'].each do |document|
                      if document['.tag'] == "file" 
                        

                          file_path = "#{document['path_display']}"
                          now_time = Time.now.strftime("%m%d%y%H%M%S")
                          file_name = "#{now_time}#{document['name']}"
                          file_name = file_name.gsub(" ","_")
                          if_doc = FolderFile.all(:custom_folder_id => "#{lfolder_id}", :dropbox_name => "#{document['name']}")
                          
                          if if_doc.blank?
                            # contents, metadata = client.get_file_and_metadata("#{file_path}")
                            
                            ################### Fetch Data ##########################
                            uri = URI.parse("https://api.dropboxapi.com/2/files/get_temporary_link");
             
                            http = Net::HTTP.new(uri.host, uri.port)
                            http.use_ssl = true
                            http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                            
                            request = Net::HTTP::Post.new(uri.request_uri)
                            data = {"path" => "#{document['path_display']}"}
                            jdata = data.to_json
                            response = http.post(uri.path, jdata, @headers)
                            rsp = response.body
                            doc_data = JSON.parse(rsp)
                            contents = open("#{doc_data['link']}").read
                          ################### End Fetch Data ########################## 

                            require 'open-uri'
                            uId = current_user.id
                            File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
                              file.write contents
                              ############# Google Cloud Storage ###########
                                
                                structure = "#{current_user.id}/#{@new_id}/#{file_name}"
                                store_data = StorageBucket.files.new(
                                  key: "#{structure}",
                                  body: contents,
                                  public: true
                                );
                                # abort("#{store_data.inspect}")
                                store_data.save
                              storage_url = store_data.public_url 
                              ############# Google Cloud Storage ###########
                              up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
                              file_kb = up_size.to_f/1024
                              @file_mb = file_kb.to_f/1024

                              doc = FolderFile.new
                                  doc.loan_id = @new_id.to_i
                                  doc.name = "#{file_name}"
                                  unless current_user.blank?
                                    doc.user_id = current_user.id
                                  else
                                    doc.user_id = "outsider"
                                  end
                                  doc.custom_folder_id = "#{lfolder_id}"
                                  doc.url = "#{storage_url}"
                                  doc.dropbox_name = "#{document['name']}}"
                                  doc.file_size = @file_mb
                                  doc.from = "google"
                                  doc.save()
                                  # abort("#{doc.inspect}")
                                  File.delete("#{Rails.root}/public/temp/#{file_name}")
                          end
                        end


                      end
                    end
                  end

                end
                ############# End Loan Documents ############
              end
            end
            ############## End Loan Data ##################
    end
    recent('desc') 
  end
  ####################### End Sync Folders ############################

  ####################### Unzip Folder #################################

 def unzip_folder
   all_files = Array.new
   Dir.entries("#{Rails.root}/public/temp/unzip_082916120916/IDV/ziploan2/documents").each do |f| 
    all_files << f 
   end
   abort("#{all_files.inspect}")


  FileUtils.rm_rf("#{Rails.root}/public/temp/unzip_filesd")
  abort("gss")
    require 'zip'

    ############################ Read Directory Code #############################

      $dir_target = "#{Rails.root}/public/temp/unzip_filesd/IDV"
      dirList = Array.new
      Dir.entries("#{$dir_target}").each do |f| 
        
        dirList << f
        # if File.directory?(f)
          # puts "#{f}\n"
        # end
      end
      abort("#{dirList.inspect}")

    ############################ End Read Directory Code #########################




    file_name = "#{Rails.root}/public/temp/IDV.zip"
    all_files = Array.new
    Zip::File.open("#{file_name}") do |zipfile|
      zipfile.each do |zfile|
        all_files << zfile.inspect
      end
    end
    
    abort("#{all_files.inspect}")
  end

  ####################### End Unzip Folder #################################

  def upload_zip

  err = 0
  begin
   files =  params[:files] 
   # abort("#{files}")
   @if_storage = check_zipfolder_size(files)
   # abort("#{@if_storage}")
   # abort("#{params[:files]}")
   if @if_storage != "false"
      require 'zip'
      # FileUtils.rm_rf("#{Rails.root}/public/temp/unzip_082916132041")


   
     output = Hash.new
     output['files']=Array.new

     #fsize =  number_to_human_size(files.size)
      #abort("#{fsize}")

   
     files.each do |file_io|
       fsize =  file_io.size
        file_kb = fsize.to_f/1024
        @file_mb = file_kb.to_f/1024

        # ext = Rack::Mime::MIME_TYPES.invert["#{file_io.content_type}"]
        # @file_new = "zfoldr_" +Time.now.strftime("%m-%d-%y_%H:%M:%Sn")+ext
        
        # File.open(Rails.root.join('public', 'temp', "#{@file_new}"), 'wb') do |file|
        #   contents = file_io.read
        #   file.write(contents)
        # end 
        compressed_path = "#{Rails.root}/public/temp/#{@if_storage}"
        # all_loans = Hash.new 
        @all_loans = Array.new
        loan_name = Array.new
        @i=0

        ##################### Fetch All loan Names ###################################
        Zip::File.open("#{compressed_path}") do |zipfile|
          zipfile.each do |zfile|
            
             @foldername = "unzip_"+Time.now.strftime("%m%d%y%H%M%S")
             uncompressed_path = File.join("#{Rails.root}/public/temp/#{@foldername}", zfile.name)
             zipfile.extract(zfile, uncompressed_path) unless File.exist?(uncompressed_path)
             
             name_array = zfile.name.split('/')
             size_array = name_array.length
             
             if size_array == 2
               if !loan_name.include? name_array[1]
                # abort("#{name_array[1]}")
                unless name_array[1].blank?
                  loan_info = Hash.new
                 
                  begin
                    loan_info['name'] = "#{name_array[1]}"
                    rescue Exception => exc
                    if exc.message
                      abort("#{name_array[1]}")
                    end
                  end
                  loan_name << name_array[1]
                  @last_loan = Loan.last
                  @new_id = @last_loan.id+1
                  loan_info['id'] = @new_id
                  dbLoan = Loan.new()
                  dbLoan.id = @new_id.to_i
                  dbLoan.name = "#{name_array[1]}"
                  dbLoan.dropbox_name = "#{name_array[1]}"
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
                  
                  loanInfo = Hash.new
                  loanInfo['name'] = "#{name_array[1]}"
                  loanInfo['_LoanName'] = "#{name_array[1]}"
                  dbLoan.email=current_user.email
                  dbLoan.info = loanInfo
                  time_nw = Time.now
                  dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
                  dbLoan.created_at=Time.now
                  dbLoan.save
                  # @i = @i+1
                  @all_loans << loan_info
                end          
               end
             end 
             ##################### Fetch All loan Names #################################

          end
        end
     end
     unless @all_loans.blank?
        # abort("#{@foldername}")
        # FileUtils.rm_rf("#{Rails.root}/public/temp/unzip_082916130033") 


        check = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV")
        if check == true
          @all_loans.each do |loan|
            @loanInfo = Loan.find_by_id(loan['id'].to_i)
            
            ############################ Fetch Images ################################################
            check_images = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/images")
            @img = "images"
            if check_images  == false
              check_images = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/Images")
              @img = "Images"
            end
            if check_images == true
              Dir.entries("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@img}").each do |f| 
                if f != ".." && f != "."
                  file_cont = open("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@img}/#{f}").read
                   # abort("#{file_cont}")
                  now_time = Time.now.strftime("%m%d%y%H%M%S")
                  file_name = "#{now_time}_#{f}"
                  require 'open-uri'
                  uId = current_user.id
                  File.open(Rails.root.join('public', 'temp', "#{file_name}"), 'wb') do |file|
                    file.write file_cont
                    ############# Google Cloud Storage ###########
                    
                    structure = "#{current_user.id}/#{@loanInfo.id}/#{file_name}"

                      store_data = StorageBucket.files.new(
                        key: "#{structure}",
                        body: file_cont,
                        public: true
                      );
                      
                    store_data.save
                   
                    ############# Google Cloud Storage ###########
                    up_size = File.size("#{Rails.root}/public/temp/#{file_name}")
                    file_kb = up_size.to_f/1024
                    @file_mb = file_kb.to_f/1024
                    image = Image.new(:loan_id=>@loanInfo.id.to_i, :file_size=>@file_mb, :user_id=>"#{current_user.id}", :from=>"google", :file_id=>structure, :name=>"#{file_name}", :url=>"#{store_data.public_url}");
                    image.featured = false
                    image.save()
                  end
                end
              end
            end
            ############################ End Fetch Images ###########################################

            ############################ Fetch Documents #################################################
            check_documents = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/documents")
            @doc  = "documents"
            if check_documents  == false
              check_documents = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/Documents")
              @doc  = "Documents"
            end 
            if check_documents == true
              # abort("Here")
              lfolder = CustomFolder.new
              lfolder.folder_name = "ZipFolder"
              lfolder.loan_id = @loanInfo.id.to_i
              unless current_user.id.blank?
                lfolder.user_id = "#{current_user.id}"
              end 
              lfolder.save

              Dir.entries("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@doc}").each do |doc|
                if doc != ".." && doc != "."
                  file_cont = open("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@doc}/#{doc}").read
                  now_time = Time.now.strftime("%m%d%y%H%M%S")
                  file_name = "#{now_time}_#{doc}"
                  structure = "#{current_user.id}/#{@loanInfo.id}/#{file_name}"

                  store_doc = StorageBucket.files.new(
                    key: "#{structure}",
                    body: file_cont,
                    public: true
                  );
                      
                  store_doc.save

                  up_size = doc.size
                  file_kb = up_size.to_f/1024
                  @file_mb = file_kb.to_f/1024

                  doc = FolderFile.new
                  doc.loan_id = @loanInfo.id.to_i
                  doc.name = "#{file_name}"
                  unless current_user.blank?
                    doc.user_id = current_user.id
                  else
                    doc.user_id = "outsider"
                  end
                  doc.custom_folder_id = "#{lfolder.id}"
                  doc.url = "#{store_doc.public_url}"
                  doc.file_size = @file_mb
                  doc.from = "google"
                  doc.save()
                  # abort("#{doc.inspect}")

                end
              end
            end
            ############################ End Fetch Documents ################################################
          
          end
        end
     end
     FileUtils.rm_rf("#{Rails.root}/public/temp/#{@if_storage}") 
     FileUtils.rm_rf("#{Rails.root}/public/temp/#{@foldername}")    
   
   else
    err = 2
   end
   rescue Exception => exc
   if exc.message
    err = 1
    abort("#{exc.message}")
   end
  end
  if err == 1
    render text:"error"
  elsif err==2
    render text:"memmory"
  else
    
    render json: output
  end
   
  
  end

  def check_storage
      unless current_user.blank?
      ##################### Memmory Size ######################

      docs = Document.where(:user_id=>"#{current_user.id}").fields(:file_size).all
      file_size = 0
      
      docs.each do |doc|
        unless doc.file_size.blank?
          file_size += doc.file_size
        end
      end

      other_docs = FolderFile.where(:user_id=>"#{current_user.id}").fields(:file_size).all
      other_docs.each do |other_doc|
        unless other_doc.file_size.blank?
          file_size += other_doc.file_size
        end
      end

      loan_images = Image.where(:user_id=>"#{current_user.id}").fields(:file_size).all
      loan_images.each do |loan_image|
        unless loan_image.file_size.blank?
          file_size += loan_image.file_size
        end
      end

      # abort("Documents #{docs.inspect} <br> #{other_docs.inspect} <br> #{loan_images.inspect}")
      @bucket_size = file_size

      ##################### Memmory Size End ##################
      

      ################# Bucket Size ###########################
      
      @bucket_mb = @bucket_size
      if @adminLogin != true
        if !@infoBroker.blank? 
            
          munit = current_user.max_storage.gsub(/\d+/,'')
          mint = current_user.max_storage.to_i

          if munit == "MB"
            unless current_user.expand_memory.blank?
              @max_size = mint.to_i+10240 
            else
              @max_size = mint.to_i
            end
          elsif munit == "GB"
            unless current_user.expand_memory.blank?
              mint = mint.to_i*1024
              @max_size = mint.to_i+10240 
            else
              mint = mint.to_i*1024
              @max_size = mint.to_i
            end
          end
              

          
          if @bucket_mb < @max_size
            @fileUpload = "true"
            @size_left = @max_size.to_i - @bucket_mb.to_f
            @size_left_kb = @size_left * 1024 * 1024
          else
            @fileUpload = "false"
          end
        end
      else
        @fileUpload = "true"
      end

         
        
          # abort("#{@fileUpload}")

      if @adminLogin == true
        @fileUpload = "true"
      end

    

      ################# Bucket Size End #########################

      ################ Max Upload ###############################

        if @adminLogin == true
          unless current_user.max_upload.blank?
            if current_user.max_upload == "No File Cap"
              @max_upload = "No File Cap"
            else
              munit = current_user.max_upload.gsub(/\d+/,'')
              mint = current_user.max_upload.to_i 
              if munit == "GB"
                @max_upload = mint.to_i * 1024 * 1024 * 1024
              else
                @max_upload = mint.to_i * 1024 * 1024
              end
            end
          end
        end

      ################ End Max Upload ###############################



    end

    return "#{@size_left}"
  end

############################ Check Dropbox Size #################################
   def check_dropbox_size


    require 'dropbox_sdk'

    # app_key = '8iwo9nfhflpkf1c'
    # app_secret = 'stja77zxhgdlm9n'

    app_key = 'ls1qvq2ynybwv19'
    app_secret = 'lqkgklyc6ttuq5e'

    uInfo = DropboxToken.find_by_user_id("#{current_user.id}")
    access_token, user_id = "#{uInfo.token}"
    client = DropboxClient.new(access_token)
    info = client.account_info().inspect
    all_folders = params[:folders].split(',')
    total_size = Array.new
    all_folders.each do |afolder|
            check = Loan.find_by_dropbox_name("#{afolder}")
            
            if check.blank?
              @last_loan = Loan.last
              @new_id = @last_loan.id+1
              dbLoan = Loan.new()
              dbLoan.id = @new_id.to_i
              dbLoan.name = "#{afolder}"
              dbLoan.dropbox_name = "#{afolder}"
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
              
              loanInfo = Hash.new
              loanInfo['name'] = "#{afolder}"
              dbLoan.email=current_user.email
              dbLoan.info = loanInfo
              time_nw = Time.now
              dbLoan.created_date = time_nw.strftime("%Y-%m-%d %H:%M:%S")
              dbLoan.created_at=Time.now
              # dbLoan.save
            else
              @loanInfo = Loan.find_by_dropbox_name("#{afolder}")
              @new_id = @loanInfo.id 
            end

            ############## Loan Data ##################
            loan_data = client.metadata("/IDV/#{afolder}")
            # abort("#{loan_data.inspect }")
            unless loan_data['contents'].blank?
              loan_data['contents'].each do |ldata|
                
                 begin
                    parent_path = "/IDV/#{afolder}"
                    rescue Exception => exc
                    if exc.message
                      abort("#{folder.inspect}")
                    end
                  end
                ############## Loan Images ##############
                path = "#{parent_path}/images"
                if ldata['path'] == path
                    loan_images = client.metadata("#{ldata['path']}")
                  loan_images['contents'].each do |limages|
                    if limages['is_dir'] == false 

                      file_path = "#{limages['path']}"
                      file_array = file_path.split("/")
                        now_time = Time.now.strftime("%m%d%y%H%M%S")
                        file_name = "#{now_time}#{file_array.last}"
                        file_name = file_name.gsub(" ","_")
                        checkImage = Image.all(:dropbox_name => "#{file_array.last}", :loan_id => @new_id.to_i)
                        file_kb = 0 
                        file_mb = 0
                        if checkImage.blank?
                          file_kb = limages['bytes'].to_f/1024
                          file_mb = file_kb.to_f/1024
                          total_size << file_mb.round(2)
                        end
                    end
                  end
                end
                ############## End Loan Images ##############

                ############# Loan Documents ############
                path = "#{parent_path}/documents"
                if ldata['path'] == path
                  
                  loan_documents = client.metadata("#{ldata['path']}")
                  unless loan_documents['contents'].blank?
                    lfolder = CustomFolder.first(:loan_id => @new_id.to_i, :folder_name => "Dropbox")

                    if lfolder.blank?
                      lfolder = CustomFolder.new
                      lfolder.folder_name = "Dropbox"
                      lfolder.dropbox_name = "Dropbox"
                      lfolder.loan_id = @new_id.to_i
                      unless current_user.id.blank?
                        lfolder.user_id = "#{current_user.id}"
                      end 
                      lfolder.save
                    end
                    # abort("#{lfolder.id}")
                    lfolder_id = lfolder.id
                    loan_documents['contents'].each do |document|
                      if document['is_dir'] == true
                        
                      else
                        

                          file_path = "#{document['path']}"
                        file_array = file_path.split("/")
                          now_time = Time.now.strftime("%m%d%y%H%M%S")
                          file_name = "#{now_time}#{file_array.last}"
                          file_name = file_name.gsub(" ","_")
                          if_doc = FolderFile.all(:custom_folder_id => "#{lfolder_id}", :dropbox_name => "#{file_array.last}")
                           file_kb = 0 
                           file_mb = 0
                          if if_doc.blank?
                            file_kb = document['bytes'].to_f/1024
                            file_mb = file_kb.to_f/1024
                            total_size << file_mb.round(2)
                          end


                      end
                    end
                  end

                end
                ############# End Loan Documents ############
              end
            end
            ############## End Loan Data ##################
    end
    sum_size = total_size.inject(0, :+)
    sum_size = sum_size.to_f  
    # abort("#{sum_size}")
    bucket_size = check_storage()
    bucket_size = bucket_size.to_f
    # abort("#{sum_size}/#{bucket_size}")
    if bucket_size>=sum_size
      render text: "true"
    else
      render text: "false"
    end

  end
######################### End Check Dropbox Size ############################## 

############################ Check Zipfolder Size #############################
  def check_zipfolder_size files
    err = 0
  # begin 
    require 'zip'
    # FileUtils.rm_rf("#{Rails.root}/public/temp/unzip_082916132041")
   files = files
   output = Hash.new
   output['files']=Array.new

   #fsize =  number_to_human_size(files.size)
   #abort("#{fsize}")
   total_size = Array.new
   
   files.each do |file_io|
     fsize =  file_io.size
      file_kb = fsize.to_f/1024
      @file_mb = file_kb.to_f/1024

      ext = Rack::Mime::MIME_TYPES.invert["#{file_io.content_type}"]
      @file_new = "zfoldr_" +Time.now.strftime("%m-%d-%y_%H:%M:%S")+ext
      
      File.open(Rails.root.join('public', 'temp', "#{@file_new}"), 'wb') do |file|
        contents = file_io.read
        file.write(contents)
      end 
      compressed_path = "#{Rails.root}/public/temp/#{@file_new}"
      # all_loans = Hash.new 
      @all_loans = Array.new
      loan_name = Array.new
      @i=0

      ##################### Fetch All loan Names ###################################
      Zip::File.open("#{compressed_path}") do |zipfile|
        zipfile.each do |zfile|
          
           @foldername = "unzip_"+Time.now.strftime("%m%d%y%H%M%S")
           uncompressed_path = File.join("#{Rails.root}/public/temp/#{@foldername}", zfile.name)
           zipfile.extract(zfile, uncompressed_path) unless File.exist?(uncompressed_path)
           
           name_array = zfile.name.split('/')
           size_array = name_array.length
           
           if size_array == 2
             if !loan_name.include? name_array[1]
              # abort("#{name_array[1]}")
              unless name_array[1].blank?
                loan_info = Hash.new
               
                begin
                  loan_info['name'] = "#{name_array[1]}"
                  rescue Exception => exc
                  if exc.message
                    abort("#{name_array[1]}")
                  end
                end
               @all_loans << loan_info
              end          
             end
           end 
           ##################### Fetch All loan Names #################################

        end
      end
   end
   unless @all_loans.blank?
    # abort("#{@foldername}")
    # FileUtils.rm_rf("#{Rails.root}/public/temp/unzip_082916130033") 


    check = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV")
    if check == true
      @all_loans.each do |loan|
        @loanInfo = Loan.find_by_id(loan['id'].to_i)
        
        ############################ Fetch Images ################################################
        check_images = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/images")
        @img = "images"
        if check_images  == false
          check_images = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/Images")
          @img = "Images"
        end
        if check_images == true
          Dir.entries("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@img}").each do |f| 
            if f != ".." && f != "."
              file_kb = 0
              @file_mb = 0
              up_size = File.size("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@img}/#{f}")
              file_kb = up_size.to_f/1024
              @file_mb = file_kb.to_f/1024
              total_size << @file_mb
            end
          end
        end
        ############################ End Fetch Images ###########################################

        ############################ Fetch Documents #################################################
        check_documents = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/documents")
        @doc  = "documents"
        if check_documents  == false
          check_documents = File.directory?("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/Documents")
          @doc  = "Documents"
        end 
        if check_documents == true
          # abort("Here")
          

          Dir.entries("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@doc}").each do |doc|
            if doc != ".." && doc != "."
              file_kb = 0
              @file_mb = 0
              file_cont = open("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@doc}/#{doc}").read
              up_size = File.size("#{Rails.root}/public/temp/#{@foldername}/IDV/#{loan['name']}/#{@doc}/#{doc}")
              file_kb = up_size.to_f/1024
              @file_mb = file_kb.to_f/1024
              total_size << @file_mb
            end
          end
        end
        ############################ End Fetch Documents ################################################
      
      end
    end
   end
   # FileUtils.rm_rf("#{Rails.root}/public/temp/#{@file_new}") 
   FileUtils.rm_rf("#{Rails.root}/public/temp/#{@foldername}")    
   # abort("#{total_size.inspect}")

    sum_size = total_size.inject(0, :+)
    sum_size = sum_size.to_f  
    # abort("#{sum_size}")

    bucket_size = check_storage()
    bucket_size = bucket_size.to_f
    # abort("#{sum_size}/#{bucket_size}")
    # abort("#{sum_size}/#{bucket_size}")
    if bucket_size>=sum_size
      return "#{@file_new}"
    else
      return "false"
    end
end
######################### End Check Zipfolder Size ############################## 
 def cron_upload
    
    
    # abort("dfsdf")
    begin
      user_ids = SyncLoan.all(:status => 0, :process.ne =>"processing")
      # abort("#{}")
      user_ids.each do |userid|
        update_syn = SyncLoan.find_by_id(userid.id)
        update_syn.process = "processing"
        update_syn.save 

        user_info = User.find_by_id(userid.user_id)

        uInfo = DropboxToken.find_by_user_id("#{user_info.id}")
        # abort("#{uInfo.inspect}")
        access_token, user_id = "#{uInfo.token}"
        # client = DropboxClient.new(access_token)
        
        # info = client.account_info().inspect
        
        @names = Array.new
        @roles = user_info.roles
        @roles.each do |role|
          @names << role.name
        end
        @adminLogin = @names.include?('Admin') 

        if @adminLogin == true
          @all_loans = Loan.where(:delete_admin.ne => 1, :delete.ne =>1).fields(:name).order(:id.desc).all
          # abort("#{@all_loans.inspect}")
        else
          @all_loans = Loan.where(:email => "#{user_info.email}", :delete_admin.ne => 1, :delete.ne =>1 ).fields(:name).order(:id.desc).all
        end
         @doc_status = Array.new
         @headers = {"Authorization" => "Bearer #{access_token}", "Content-Type" => "application/json" }
                      
        unless @all_loans.blank?
          @all_loans.each do |loan|
            
            ############################## Images Upload ############################
            if @adminLogin == true
              images = Image.where(:loan_id => loan.id.to_i).fields(:name, :url).all
            else
              images = Image.where(:loan_id => loan.id.to_i, :user_id => "#{user_info.id}").fields(:name, :url).all
            end
            unless images.blank?
              
              images.each do |image|
                # check = check_file_existance("/IDV/#{loan.name}/images/#{image.name}","#{access_token}")
                # # check = "no"
                # if check == "no"
                  unless image.url.blank?
                      uri = URI.parse("https://api.dropboxapi.com/2/files/save_url");
                      http = Net::HTTP.new(uri.host, uri.port)
                      http.use_ssl = true
                      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                      
                      request = Net::HTTP::Post.new(uri.request_uri)
                      data = {"path" => "/IDV/#{loan.name}/images/#{image.name}", "url" => "#{image.url}"}
                      jdata = data.to_json
                      response = http.post(uri.path, jdata, @headers)
                      rsp = response.body
                      @doc_status << rsp
                      # abort("#{@doc_status.inspect}")
                  else
                   
                  end
                end
              end
            # end
            ########################### End Image Upload #################################
            

            ########################### Documents Upload ##################################
             if @adminLogin == true
                documents = Document.where(:loan_id => loan.id.to_i).fields(:name, :url).all
             else
                documents = Document.where(:loan_id => loan.id.to_i, :user_id => "#{user_info.id}").fields(:name, :url).all
             end
             
             unless documents.blank?
                documents.each do |document|
                # check = check_file_existance("/IDV/#{loan.name}/documents/#{document.name}","#{access_token}")
                # if check == "no"

                  unless document.url.blank?
                    
                      
                      # abort("#{file.inspect}")
                      uri = URI.parse("https://api.dropboxapi.com/2/files/save_url");
                      http = Net::HTTP.new(uri.host, uri.port)
                      http.use_ssl = true
                      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                      
                      request = Net::HTTP::Post.new(uri.request_uri)
                      data = {"path" => "/IDV/#{loan.name}/documents/#{document.name}", "url" => "#{document.url}"}
                      jdata = data.to_json
                      response = http.post(uri.path, jdata, @headers)
                      rsp = response.body
                      @doc_status << rsp
                  else
                   
                  end

                end
               end
             
             # end
                          

            ########################### End Documents Upload ##################################

             ########################## Custom Folder Files ####################################
              if @adminLogin == true
                ffiles = FolderFile.where(:loan_id => loan.id.to_i).fields(:name, :url).all
              else
                ffiles = FolderFile.where(:loan_id => loan.id.to_i, :user_id => "#{user_info.id}").fields(:name, :url).all
              end
              unless ffiles.blank?
                
                ffiles.each do |ffile|
                  # check = check_file_existance("/IDV/#{loan.name}/documents/#{ffile.name}","#{access_token}")
                  # if check == "no"
                    unless ffile.url.blank?
                     uri = URI.parse("https://api.dropboxapi.com/2/files/save_url");
                      http = Net::HTTP.new(uri.host, uri.port)
                      http.use_ssl = true
                      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
                      
                      request = Net::HTTP::Post.new(uri.request_uri)
                      data = {"path" => "/IDV/#{loan.name}/documents/#{ffile.name}", "url" => "#{ffile.url}"}
                      jdata = data.to_json
                      response = http.post(uri.path, jdata, @headers)
                      rsp = response.body
                      @doc_status << rsp
                          
                    else
                      
                    end
                end
              end
                # abort("#{@doc_status.inspect}")
              # end
            ########################## End Custom Folder Files ################################
            log = Logger.new 'log/dropbox.log'
            log.debug "Success Dropbox ~~~~~~~~~~~~~~~~~ #{loan.name}"
          end
          
        end
        update_sync = SyncLoan.find_by_id(userid.id)
        update_sync.status = 1
        update_sync.process = "completed"
        update_sync.save 
        LoanUrlMailer.sync_successfully(update_sync.user_id).deliver
      end
      rescue Exception => exc
      if exc.message
        log = Logger.new 'log/dropbox.log'
        log.debug "Error Dropbox ~~~~~~~~~~~~~~~~~ #{exc.message}"
      end
    end
    
    render text: "done" 
 end

 ################## Check File Existance in Dropbox #############################
 def check_file_existance path=nil,token=nil

      # abort("#{path} --- #{uId}")
      headers = {"Authorization" => "Bearer #{token}", "Content-Type" => "application/json" }
      uri = URI.parse("https://api.dropboxapi.com/2/files/get_metadata");
       
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
      
      request = Net::HTTP::Post.new(uri.request_uri)
      data = {"path" => "#{path}"}
      jdata = data.to_json
      response = http.post(uri.path, jdata, headers)
      rsp = response.body
      objArray = JSON.parse(rsp)
      if objArray['error_summary']
          response = "no"
      else
          response = "yes"
      end
     
      return response
    
 end

 ################## End Check File Existance in Dropbox ######################### 

 ###################### HTTP Dropbox ######################################
  def upload_to_dropbox
    headers = {"Authorization" => "Bearer LFKG6uIb2YAAAAAAAAAA6LXWSL_gdGKSvEpMqxEt8YmTW2k0KWdna3QgodzIGycn", "Content-Type" => "application/json" }
    uri = URI.parse("https://api.dropboxapi.com/2/files/save_url");
    # abort("#{uri.port}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Sets the HTTPS verify mode
    
    request = Net::HTTP::Post.new(uri.request_uri)
    # request.set_form_data({"api_key" => "aae5b42c3f0997b8c6c5596b9c1856d89fd25ebe"})
    # response = http.request(request)
    # response.set_form_data(uri.path, {"path" => "/IDV/abc/images/090816005417_images.jpeg", "url" => "https://idealview.storage.googleapis.com/571721054749e85c11000002/5106/090816005417_images.jpeg"}, headers)
    data = {"path" => "/IDV/abc/images/090816005417_images.jpeg", "url" => "https://idealview.storage.googleapis.com/571721054749e85c11000002/5106/090816005417_images.jpeg"}
    jdata = data.to_json
    response = http.post(uri.path, jdata, headers)
    rsp = response.body
    abort("#{rsp.inspect}")
  end
 ###################### End HTTP Dropbox ######################################

 def upload_loan_data
  sync = SyncLoan.find_by_user_id("#{current_user.id}")
  if sync.blank?
    info = SyncLoan.new
    info.user_id = "#{current_user.id}"
    info.process = "queue"
    info.status = 0
    info.save
  else
    info = SyncLoan.find_by_user_id("#{current_user.id}")
    info.process = "queue"
    info.status = 0
    info.save
  end
  render text:"done"
 end

 end