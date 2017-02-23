class AccountManagementController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  # helper_method :memmory
  require 'date'


  
  def index
  	

    # @users =  User.all
    # @users.each do |user|
    #   @uInfo = User.find_by_id(user.id)
    #   unless user.name.blank?
    #     @uInfo.name = user.name.camelize
    #   end
    #   unless user.broker.blank?
    #     if user.broker['plan']
    #       if user.broker['plan'] == "PRO"
    #         # abort("#{@uInfo.inspect}")
    #         @uInfo.plan = "free"
    #       else
    #         @uInfo.plan = user.broker['plan'].downcase
    #       end
    #       # abort("#{user.broker['plan']}")
          
    #     elsif user.broker.lender == 1
    #       @uInfo.plan = "lender"
    #     else
    #       @uInfo.plan = "free"
    #     end

    #     if user.plan == "business"
    #       if user.max_users.blank?
    #         @uInfo.max_users = 5
    #       end
    #       if user.max_lenders.blank?
    #         @uInfo.max_lenders = "No Limit"
    #       end
    #       if user.max_storage.blank?
    #         @uInfo.max_storage = "5Gb"
    #       end
    #       if user.max_upload.blank?
    #         @uInfo.max_upload = "25Mb"
    #       end
    #       if user.pipelines.blank?
    #         @uInfo.pipelines = 1
    #       end
    #       if user.req_docs.blank?
    #         @uInfo.req_docs = 1
    #       end
    #       @uInfo.save
    #     elsif user.plan == "enterprise"
    #       if user.max_users.blank?
    #         @uInfo.max_users = 15
    #       end
    #       if user.max_lenders.blank?
    #         @uInfo.max_lenders = "No Limit"
    #       end
    #       if user.max_storage.blank?
    #         @uInfo.max_storage = "100Gb"
    #       end
    #       if user.max_upload.blank?
    #         @uInfo.max_upload = "No File Cap"
    #       end
    #       if user.pipelines.blank?
    #         @uInfo.pipelines = 1
    #       end
    #       if user.req_docs.blank?
    #         @uInfo.req_docs = 1
    #       end
    #       if user.forward_email.blank?
    #         @uInfo.forward_email = 1
    #       end
    #       if user.market_access.blank?
    #         @uInfo.market_access = 1
    #       end
    #       @uInfo.save
    #     else
    #       if user.max_users.blank?
    #         @uInfo.max_users = 1
    #       end
    #       if user.max_lenders.blank?
    #         @uInfo.max_lenders = 5
    #       end
    #       if user.max_storage.blank?
    #         @uInfo.max_storage = "1Gb"
    #       end
    #       if user.max_upload.blank?
    #         @uInfo.max_upload = "10Mb"
    #       end
    #       @uInfo.save
    #     end
    #   end

    #   @uInfo.save :safe =>true, :validate => false
    # end
    # abort("#{@users.inspect}")

  	@flash = "no"
  	ref = "#{request.referer}"
  	if ref.include? "edit_account"
  	   @flash = "yes"
  	end

    users = User.all(:is_admin.ne => true)
    @ids = Array.new
    users.each do |user|
    	unless user.broker.blank?
    		@ids << user.id
      end
      uInfo = User.find_by_id("#{user.id}")
      uInfo.sub_users = user.count_users+1
      uInfo.num_lenders = user.share_lenders
      uInfo.int_upload = user.max_upload.to_i
      uInfo.int_storage = user.memory.to_i
      uInfo.save  :safe =>true, :validate => false
    end
    # abort("#{@ids.inspect}")

    unless params[:page].blank?
      @total = User.count(:id=>@ids, :is_admin.ne => true)
      @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:page], :page => params[:page], :total_entries => @total, :order => :id.desc)
    else
      @total = User.count(:id=>@ids, :is_admin.ne => true)
      @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :id.desc)
    end


    @partition = @total/10
    @partitions = @partition.round
    @check = @partition*10
    if @check<@total
      @partitions = @partition + 1
    end
    @records = 10
    @page = 1
  
    # abort("#{@brokers.inspect}")

    # brokers = Broker.all(:lender => 1)
    # brokers.each do |broker|
    #   lbroker = Broker.find_by_id(broker.id)
    #   lbroker.plan = "lender"
    #   lbroker.save
    #   unless lbroker.email.blank?
    #     uInfo = User.find_by_email("#{lbroker.email}")
    #     unless uInfo.blank?
    #       uInfo.max_users = 1
    #       uInfo.max_lenders = 5
    #       uInfo.max_storage = "1Gb"
    #       uInfo.max_upload = "10Mb"
    #       uInfo.save
    #     end
    #   end
    # end
    
  end

  def paging
    @flash = "no"
    ref = "#{request.referer}"
    if ref.include? "edit_account"
       @flash = "yes"
    end

    @users = User.all
   
   
    @ids = Array.new
    ############################ Search #####################################
    
    if params[:user_type] != "all"
      @user_type = "#{params[:user_type]}"
    end

    unless params['search'].blank?
      srch = "/"+params['search']+"/"
      srch_string = params['search'].downcase

      
      
      unless @users.blank? 
        # @all_roles = Array.new
        # abort("#{srch_string}")
        @users.each do |user|
          
          @roles = user.roles
                      
          @names = Array.new
          unless  user.broker.blank?
            @roles.each do |role|
                @names << role['name']
            end 
          end
          
          unless @names.include? "Admin"
            unless user.broker.blank?
              # sub_roles = Hash.new
              # sub_roles['roles'] = @names
              # sub_roles['email'] = user.email

              unless user.name.blank?
                name = user.name.downcase
               
                if name.include? srch_string

                  if params[:user_type] != "all"
                    unless user.broker['plan'].blank?
                      userType = user.broker['plan']   
                    else
                      userType = "free"
                    end 
                    
                    if userType.downcase == @user_type
                      @ids<<user.id  
                    end
                  # abort("No")
                  else
                    @ids<<user.id
                    # abort("Yes")
                  end
                end
              end

              unless user.email.blank?
                email = user.email.downcase
                if email.include? srch_string
                  if defined? @user_type
                    unless user.broker['plan'].blank?
                      userType = user.broker['plan']   
                    else
                      userType = "free"
                    end 
                    
                    if userType.downcase == @user_type
                      @ids<<user.id  
                    end
                  else
                    @ids<<user.id
                  end
                end
              end
              # @all_roles << sub_roles
            end
          end

        end
        # abort("#{@all_roles.inspect}")
      end

    
    ############################ Search #####################################
    else
         # abort("#{@users.inspect}")
        @users.each do |user|
          unless user.broker.blank?
              # abort("#{user.broker.inspect}")
            if params[:user_type] != "all"
              unless user.broker['plan'].blank?
                userType = user.broker['plan']   
              else
                userType = "free"
              end 
              # abort("#{@user_type}")
              
              if userType.downcase == @user_type
                @ids<<user.id  
              end
              
            else
              @ids<<user.id
            end
          end
        end
    end

    # abort("#{@ids.inspect}")

    unless params[:page].blank?

      @total = User.count(:id=>@ids, :is_admin.ne => true)
      # abort("#{@total} -- #{@ids}")
      if params[:sort_by] == "name"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records].to_i, :page => params[:page].to_i, :total_entries => @total.to_i, :order => :name.asc)
            # abort("#{params[:records]} == #{params[:page]} == #{@total} == #{@ids.inspect}")
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :name.desc)
        end
      elsif params[:sort_by] == "email"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :email.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :email.desc)
        end
      elsif params[:sort_by] == "plan"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :plan.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :plan.desc)
        end
      elsif params[:sort_by] == "max_upload"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :max_upload.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :max_upload.desc)
        end
      elsif params[:sort_by] == "sub_user"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :sub_users.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :sub_users.desc)
        end
      elsif params[:sort_by] == "num_lenders"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :num_lenders.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :num_lenders.desc)
        end
      elsif params[:sort_by] == "int_upload"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :int_upload.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :int_upload.desc)
        end
      elsif params[:sort_by] == "int_storage"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :int_storage.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :int_storage.desc)
        end
      else
        @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total, :order => :id.desc)
      end
      # abort("#{@brokers.inspect}")
    else
      @total = User.count(:id=>@ids, :is_admin.ne => true)
      if params[:sort_by] == "name"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :name.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :name.desc)
        end
      elsif params[:sort_by] == "email"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :email.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :email.desc)
        end
      elsif params[:sort_by] == "plan"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :plan.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :plan.desc)
        end
       elsif params[:sort_by] == "max_upload"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :max_upload.asc)
        else  
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :max_upload.desc)
        end
      elsif params[:sort_by] == "sub_user"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :sub_users.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :sub_users.desc)
        end
      elsif params[:sort_by] == "num_lenders"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :num_lenders.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :num_lenders.desc)
        end
      elsif params[:sort_by] == "int_upload"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :int_upload.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :int_upload.desc)
        end
      elsif params[:sort_by] == "int_storage"
        if params[:sort_order] == "asc"
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :int_storage.asc)
        else
          @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :int_storage.desc)
        end
      else
        @brokers = User.paginate(:id=>@ids, :is_admin.ne => true, :per_page => 10, :page => 1, :total_entries => @total, :order => :id.desc)
      end
    end

    # abort("#{@total} -- #{@brokers}")
    unless params[:records].blank?
      @partition = @total/ params[:records].to_i
      @partitions = @partition.round
      @check = @partition*params[:records].to_i
      if @check<@total
        @partitions = @partition + 1
      end
      unless params[:records].blank?
        @records = params[:records]
      else
        @records = 10
      end
      @page = params[:page]
    else
      @partition = @total/10
      @partitions = @partition.round
      @check = @partition*10
      if @check<@total
        @partitions = @partition + 1
      end
      @records = 10
      @page = 1
    end

    render partial: 'user_records'
     # @loans = Loan.paginate(:delete.ne => 1, :delete_admin.ne =>1, :archived.ne => true, :per_page => params[:records], :page => params[:page], :total_entries => @total_loans , :order => :id.desc) 
  end

  def search
    srch = "/"+params['search']+"/"
    srch_string = params['search'].downcase
    @users = User.all
    
    @ids=Array.new
    unless @users.blank? 
      @users.each do |user|
        
        @roles = user.roles
                  
	    @names = Array.new
	    unless  user.broker.blank?
	    	@roles.each do |role|
	      		@names = role['name']
	    	end	
	    end

	    unless @names.include? "Admin"
	        unless user.name.blank?
	          name = user.name.downcase
	          if name.include? srch_string
	            @ids<<user.id  
	          end
	        end

	        unless user.email.blank?
	          email = user.email.downcase
	          if email.include? srch_string
	            @ids<<user.id 
	          end
	        end
    	end

      end
    end
    # abort("#{@ids.inspect}")
  
    @brokers=User.all(:is_admin.ne => true, :id => @ids, :order => :id.desc)
    render partial: 'refresh_users'

  end

  def delete_users
    ids=params[:moredata].split(",")
    ids.each do |number|
        uInfo = User.find_by_id(number)
        Broker.delete_all(:email => "#{uInfo.email}")
        User.delete_all(:email => "#{uInfo.email}")
    end
      render text: "done" 
  end

  def edit_account
  	@uInfo = User.find_by_id("#{params[:id]}")
  	@brokrInfo = Broker.find_by_email("#{@uInfo.email}")
  	# abort("#{@uInfo.inspect}--#{@brokrInfo.inspect}")
  end

  def save_records
  	
  	uInfo = User.find_by_email("#{params[:email]}")
  	uInfo.name = "#{params[:name]}"
  	uInfo.email = "#{params[:email]}"
  	unless params[:password].blank?
  		uInfo.password = "#{params[:password]}"
     
      brokerInfo = Broker.find_by_email("#{params[:email]}")
      brokerInfo.password = "#{params[:password]}"
      brokerInfo.save

  	end
  	uInfo.max_users = params[:max_users]
  	unless params[:unlimited_lenders].blank?
      uInfo.max_lenders = "No Limit"
    else
      uInfo.max_lenders = params[:max_lenders]
    end
  	max_storage = "#{params[:max_int]}#{params[:max_unit]}"
    uInfo.max_storage = max_storage
  	unless params[:unlimited_upload].blank?
      uInfo.max_upload = "No File Cap"
    else
      max_upload = "#{params[:max_storage_int]}#{params[:max_storage_unit]}"
      uInfo.max_upload = max_upload
    end
  	unless params[:pipelines].blank?
  		uInfo.pipelines = params[:pipelines]
  	else
      uInfo.pipelines =  0
    end
  	unless params[:req_docs].blank?
  		uInfo.req_docs = params[:req_docs]
  	else
      uInfo.req_docs = 0
    end
    
    unless params[:market_access].blank?
      uInfo.market_access = params[:market_access]
    else
      uInfo.market_access = 0
    end

  	unless params[:loan_application_links].blank?
  		uInfo.loan_application_links = params[:loan_application_links]
  	else
      uInfo.loan_application_links = 0
    end
  	unless params[:forward_email].blank?
  		uInfo.forward_email = params[:forward_email]
  	else
      uInfo.forward_email = 0
    end
    # abort( "#{uInfo.inspect}")
  	uInfo.save
  	flash.now[:notice] = "Your changes has been saved succesfuly."
    redirect_to :action => "index"
  end

  def fetch_sub_brokers
    @sub_brokers=Broker.all(:parent_user => params[:id])
    render partial: 'broker_records'
  end

  def market_access
    brokerInfo = User.find_by_id("#{params[:broker_id]}")
    brokerInfo.market_access = params[:market_access].to_i
    brokerInfo.save

    render text: "done"
  end



 
 end