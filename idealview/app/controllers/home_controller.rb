class HomeController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  # before_filter :authenticate_user, :only => [:home, :profile, :setting]
  before_filter :save_login_state, :only => [:login, :login_attempt]
  

  def index

    # abort("#{params}")
    users = User.all
    uname= Array.new
    i=0
    # users = User.all
    # users.each do |user|
    #   uInfo = User.find_by_id(user.id)
    #   user_name = ""
    #   unless uInfo.name.blank?
    #     name = uInfo.username.gsub('.','');
    #     if uname.include? "#{name.downcase}"
    #       i += 1
    #       uname<<"#{name.downcase}#{i}"
    #       sub_domain = "#{name.downcase}#{i}"
    #     else
    #       uname<<name.downcase
    #       sub_domain = name.downcase
    #       sub_domain = sub_domain.gsub('_',''); 
    #     end
        
    #   else
    #     array_name = uInfo.email.split(/@/)
    #     unless uname.include? "#{array_name[0]}"
    #       i += 1
    #       uname<<"#{array_name[0].downcase}#{i}"
    #       sub_domain = "#{array_name[0].downcase}#{i}"
    #       sub_domain = sub_domain.gsub('_',''); 
    #     else
    #       uname << "#{array_name[0].downcase}"
    #       sub_domain = "#{array_name[0].downcase}"
    #        sub_domain = sub_domain.gsub('_',''); 
    #     end
    #   end
      
    #   uInfo.subdomain = sub_domain
    #   uInfo.save
    # end
    # subd = Array.new
    # users.each do |user|
    #   subd<<user.subdomain
    # end
    #  abort("#{subd.inspect}")
    # abort("#{session[:current_password]}")
    unless current_user.blank?
          # abort("#{current_user.inspect}")
        # if current_user.email=="preet@gmail.com"
        #       # abort("#{@brokerLogin}")
              
        #       ################# Transfer Data to new DB ################
        #       @user = User.find_by_email("#{current_user.email}")
        #       if @brokerLogin==true
        #         bemail = "#{current_user.email}"
        #         @broker = Broker.find_by_email(bemail.to_s)
        #       end
        #       @terms = TermCondition.find_by_type("shop_loans")
        #       MongoMapper.database = "#{current_user.username}"
        #       @userI = User.new
        #       @userI = @user
        #       @userI.save

        #       @bterm = TermCondition.find_by_type("shop_loans")
        #       if @bterm.blank?
        #         term_condition = TermCondition.new
        #         term_condition = @terms
        #         term_condition.save
        #       end 

        #       if @brokerLogin==true
        #         bemail = "#{current_user.email}" 
        #         @new_broker = Broker.find_by_email(bemail.to_s)

        #         if @new_broker.blank?
        #           brokr = Broker.new
        #           brokr = @broker
        #           brokr.save
        #         end
        #       end
        #       ################# Transfer Data to new DB ################



              
        # end
        cookies[:logoutFd] = "done"
        
        # cname="#{current_user.name}/#{request.subdomain}"
        # str = Base64.encode64("#{cname}")
        # redirect_to "https://idealview.us/?idvkey_token="+str
    else
      if cookies[:logoutFd]
        cookies.delete :logoutFd
        redirect_to "https://idealview.us/?idvaction=signout"
      end
    end
  end


################ Dashboard #########################

  def dashboard
    if current_user.blank?
      redirect_to "/users/sign_in"
    else 
      chect_server = request.base_url
    if chect_server.include? "idealview"
      if session[:idealview].blank?
        # abort("dfdff")
        cookies[:logoutFd] = "done"
         session[:idealview] = "yes" 
        cname="#{current_user.name}/#{request.subdomain}"
        str = Base64.encode64("#{cname}")
        if @adminLogin!=true
          if @lenderLogin == true && @infoBroker.plan == "lender"
            @redirect_var =  "https://idealview.us/?idvkey_token="+str+"&return_url=idealview&type=lender"
          else
            @redirect_var =  "https://idealview.us/?idvkey_token="+str+"&return_url=idealview"
          end
        else
          @redirect_var =  "https://idealview.us/?idvkey_token="+str+"&return_url=idealview"
        end
        redirect_to "#{@redirect_var}"
      end
    end
    
      @user_email = current_user.email

      @result = UserChart.find_by_user_id("#{current_user.id}")
      # abort("#{@result.inspect}")
      unless @result.blank?
        unless @result.chart_type_loan.blank?
          @chart_type_loan = @result.chart_type_loan
        else
          @chart_type_loan = "column_chart"
        end

        unless @result.chart_type_amount.blank?
          @chart_type_amount = @result.chart_type_amount
        else
          @chart_type_amount = "column_chart"
        end

        if @result.search_type == "custom"
          from_date = @result.from_date.split("-")
          @cfrom_year = "#{from_date[0]}"
          @cfrom_month = "#{from_date[1]}"
          @cfrom_day = "#{from_date[2]}"

          to_date = @result.to_date.split("-")
          # abort("#{to_date.inspect}")
          @cto_year = "#{to_date[0]}"
          @cto_month = "#{to_date[1]}"
          @cto_day = "#{to_date[2]}"

           # abort("#{@from_year}-#{@from_month}-#{@from_day} --- #{@to_year}-#{@to_month}-#{@to_date}")
        end
      else
        
          @chart_type = "column_chart"
        
      end

      ################## 30 Days Submissions ############################ 
      from_date = Time.now - 30.days
      end_date = Time.now

      current_year = end_date.strftime("%Y")
      @current_year = current_year.to_i
      @from_year = @current_year - 5
      
     
     
      # abort("#{@user_email}")
       # abort("#{from_date} -- #{end_date}")

      if @adminLogin == true
        @thirty_days_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1, :created_at.gte => from_date)
      else
        @thirty_days_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => from_date, :email => current_user.email)
      end
      
      
      # abort("#{@all_loans}")
      ################## 30 Days Submissions ############################

      ################## 30 Days Amount ############################ 
      from_date = Time.now - 30.days
      end_date = Time.now

      current_year = end_date.strftime("%Y")
      @current_year = current_year.to_i
      @from_year = @current_year - 5
      
      if @adminLogin == true
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
      else
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email ).fields(:net_loan_amount).all
      end
      
      
      @amnt = 0
      @all_loans.each do |aloan|
        unless aloan.net_loan_amount.blank?
          @amnt = aloan.net_loan_amount + @amnt    
        end
      end
      
      @thirty_days_amnt = number_to_currency(@amnt)
      ################## 30 Days Amount ############################

      ################## Last week loan ############################

      last_week = Time.now - 1.week

      from_date = last_week.at_beginning_of_week
      end_date = last_week.at_end_of_week
      sfrom_date = Date.parse("#{from_date}")
      send_date = Date.parse("#{end_date}")
      if @adminLogin == true
        @week_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1, :created_at.gte => from_date)
      else
        @week_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => from_date, :email => @user_email)
      end
      # abort("#{@week_loan}")

      ################## Last week loan ############################

      ################## Last week amount ############################

      last_week = Time.now - 1.week

      from_date = last_week.at_beginning_of_week
      end_date = last_week.at_end_of_week
      
      sfrom_date = Date.parse("#{from_date}")
      send_date = Date.parse("#{end_date}")
      if @adminLogin == true
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
      else
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email).fields(:net_loan_amount).all
      end
      @amnt = 0
      @all_loans.each do |aloan|
        unless aloan.net_loan_amount.blank?
          @amnt = aloan.net_loan_amount + @amnt    
        end
      end
      @week_amnt = number_to_currency(@amnt)

      ################## Last week amount ############################

      ################## Loan Previous month ############################

      last_month_date = Time.now - 1.month
      last_month = last_month_date.strftime("%m")
      year = last_month_date.strftime("%Y")
      
      from_date = "#{year}-#{last_month}-01"
      from_date = Date.parse("#{from_date} 00:00:00 UTC").strftime("%Y-%m-%d")
      
      days = Time.days_in_month(last_month.to_i, year.to_i)
      last_date = "#{year}-#{last_month}-#{days}"
      last_date = Date.parse("#{last_date} 00:00:00 UTC").strftime("%Y-%m-%d")
      
      start_date = from_date.to_time
      end_date = last_date.to_time

      if @adminLogin == true
        @previous_month_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => start_date)
      else
        @previous_month_loan = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => start_date, :email => @user_email)
      end
      ################## Loan Previous month ############################

      ################## Loan Previous amount ############################

        last_month_date = Time.now - 1.month
        last_month = last_month_date.strftime("%m")
        year = last_month_date.strftime("%Y")
        
        from_date = "#{year}-#{last_month}-01"
        from_date = Date.parse("#{from_date} 00:00:00 UTC").strftime("%Y-%m-%d")
        
        days = Time.days_in_month(last_month.to_i, year.to_i)
        last_date = "#{year}-#{last_month}-#{days}"
        last_date = Date.parse("#{last_date} 00:00:00 UTC").strftime("%Y-%m-%d")
        
        # abort("#{from_date} - #{last_date}")
        start_date = from_date.to_time
        end_date = last_date.to_time
        # abort("#{from_date} -- #{last_date}")

        if @adminLogin == true
          @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => start_date).fields(:net_loan_amount).all
        else
          @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => start_date, :email =>@user_email).fields(:net_loan_amount).all
        end

        @amnt = 0
        @all_loans.each do |aloan|
          unless aloan.net_loan_amount.blank?
            @amnt = aloan.net_loan_amount + @amnt    
          end
        end
          
        @previous_month_amnt = number_to_currency(@amnt)

      ################## Loan Previous amount ############################

      ################## Loan Previous Year ##############################

      last_year = Time.now - 1.year
      @last_yr =  last_year.strftime("%Y")

      from_date = last_year.at_beginning_of_year
      end_date = last_year.at_end_of_year
      
      
      
      if @adminLogin == true
        @loan_last_year = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date)
      else
        @loan_last_year = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => from_date, :email => @user_email)
      end

      ################## Loan Previous Year ##############################

        ################## Amount Previous Year ##############################

          last_year = Time.now - 1.year
          @last_yr =  last_year.strftime("%Y")

          from_date = last_year.at_beginning_of_year
          end_date = last_year.at_end_of_year
          
          if @adminLogin == true
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
          else
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email).fields(:net_loan_amount).all
          end

          @amnt = 0
          @all_loans.each do |aloan|
            unless aloan.net_loan_amount.blank?
              @amnt = aloan.net_loan_amount + @amnt    
            end
          end
          @amount_last_year = number_to_currency(@amnt)


      ################## Amount Previous Year ##############################
        


        
    end  


  end


  def user_information
    @result = UserChart.find_by_user_id("#{current_user.id}")
    @user_email = "#{current_user.email}"
    #################### User Information ################################
    

      ################### Total Loans #####################
        if @adminLogin == true
          @user_loans = Loan.count(:delete.ne => 1, :delete_admin.ne => 1)
        else
          @user_loans = Loan.count(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email)
        end
        user_end_date = Time.now
        user_from_date = user_end_date.at_beginning_of_month
        if @adminLogin == true
          @this_month = Loan.count(:delete.ne => 1, :delete_admin.ne => 1, :created_at.lte => user_end_date, :created_at.gte => user_from_date)
        else
          @this_month = Loan.count(:delete.ne => 1, :delete_broker.ne => 1,  :email => @user_email, :created_at.lte => user_end_date, :created_at.gte => user_from_date)
        end
        @average_this_month = @this_month.to_f/@user_loans.to_f
        @average_this_month = @average_this_month.round(2)
      ################### End Total Loans ##################

      ################### Loan Amount #####################
        if @adminLogin == true
          @user_loan_amounts = Loan.where(:delete.ne => 1, :delete_admin.ne => 1).fields(:net_loan_amount).all
        else
          @user_loan_amounts = Loan.where(:delete.ne => 1, :delete_broker.ne => 1,  :email => @user_email).fields(:net_loan_amount).all
        end
        @u_loan_amount = 0
        @user_loan_amounts.each do |loan_amount|
          if !loan_amount.net_loan_amount.blank?
            @u_loan_amount += loan_amount.net_loan_amount
          end
        end

        
        if @adminLogin == true
          @month_loan_amounts = Loan.where(:delete.ne => 1, :delete_admin.ne => 1, :created_at.lte => user_end_date, :created_at.gte => user_from_date).fields(:net_loan_amount).all
        else
          @month_loan_amounts = Loan.where(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email, :created_at.lte => user_end_date, :created_at.gte => user_from_date).fields(:net_loan_amount).all
        end
        @m_loan_amount = 0
        @month_loan_amounts.each do |mloan_amount|
          if !mloan_amount.net_loan_amount.blank?
            @m_loan_amount += mloan_amount.net_loan_amount
          end
        end 


        @average_loan_amount = @m_loan_amount.to_f/@u_loan_amount.to_f
        @average_loan_amount = @average_loan_amount.round(2)
      ################### End Loan Amount ##################

      ################### Loan Types #####################
        @loan_types = Array.new
        if @adminLogin == true
          @users_loan_types = Loan.where(:delete.ne => 1, :delete_admin.ne => 1).fields(:lending_type).all
        else
          @users_loan_types = Loan.where(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email).fields(:lending_type).all
        end
        @users_loan_types.each do |loan_type|
          if !loan_type.lending_type.blank?
            if !@loan_types.include? "#{loan_type.lending_type}"
              @loan_types << "#{loan_type.lending_type}"
            end
          end
        end

        @loan_type_array = Array.new
        if !@loan_types.blank?
          @loan_types.each do |loan_type|
            @type_hash = Hash.new
            if @adminLogin == true
              @type_loans = Loan.count(:delete.ne => 1, :delete_admin.ne => 1, :lending_type => "#{loan_type}")
            else
              @type_loans = Loan.count(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email, :lending_type => "#{loan_type}")
            end
            @type_hash['type'] = loan_type
            @type_hash['total'] = @type_loans
            @loan_type_array << @type_hash
          end
        end
      ###################End Loan Types #####################
      if !@result.blank?
          if @result.search_type == "custom"
            from_date = "#{@result.from_date} 00:00:00"
            end_date = "#{@result.to_date} 23:59:59"

            from_date = from_date.to_time
            end_date = end_date.to_time


          elsif @result.search_type == "last_30_days"
            from_date = Time.now - 30.days
            end_date = Time.now
          elsif @result.search_type == "previous_month_record"
            last_month_date = Time.now - 1.month
            last_month = last_month_date.strftime("%m")
            year = last_month_date.strftime("%Y")
            
            from_date = "#{year}-#{last_month}-01"
            from_date = Date.parse("#{from_date} 00:00:00 UTC").strftime("%Y-%m-%d")
            
            days = Time.days_in_month(last_month.to_i, year.to_i)
            last_date = "#{year}-#{last_month}-#{days}"
            last_date = Date.parse("#{last_date} 00:00:00 UTC").strftime("%Y-%m-%d")
            
            # abort("#{from_date} - #{last_date}")
            from_date = from_date.to_time
            end_date = last_date.to_time
          elsif @result.search_type == "last_week"
            last_week = Time.now - 1.week

            from_date = last_week.at_beginning_of_week
            end_date = last_week.at_end_of_week
            
            from_date = Date.parse("#{from_date}")
            end_date = Date.parse("#{end_date}")
            from_date = from_date.to_time
            end_date = end_date.to_time
          elsif @result.search_type == "last_year"
             last_year = Time.now - 1.year
             @last_yr =  last_year.strftime("%Y")

             from_date = last_year.at_beginning_of_year
             end_date = last_year.at_end_of_year

              from_date = from_date.to_time
              end_date = end_date.to_time
          end
            
      ################### Total Loans #####################
          show_from_date = Date.parse("#{from_date}").strftime("%d %b, %y")
          show_to_date = Date.parse("#{end_date}").strftime("%d %b, %y")

          @loan_data_display = "From #{show_from_date} To #{show_to_date}"

          if @adminLogin == true
            @fuser_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date)
          else
            @fuser_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email)
          end
      ################### End Total Loans ##################

      ################### Loan Amount #####################
        if @adminLogin == true
          @fuser_loan_amounts = Loan.where(:delete.ne => 1, :delete_admin.ne => 1, :created_at.lte => end_date, :created_at.gte => from_date).fields(:net_loan_amount).all
        else
          @fuser_loan_amounts = Loan.where(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email, :created_at.lte => end_date, :created_at.gte => from_date).fields(:net_loan_amount).all
        end
        @f_loan_amount = 0
        @fuser_loan_amounts.each do |floan_amount|
          if !floan_amount.net_loan_amount.blank?
            @f_loan_amount += floan_amount.net_loan_amount
          end
        end
      ################### End Loan Amount ##################

      ################### Loan Types #####################
        @floan_types = Array.new
        if @adminLogin == true
          @fusers_loan_types = Loan.where(:delete.ne => 1, :delete_admin.ne => 1, :created_at.lte => end_date, :created_at.gte => from_date).fields(:lending_type).all
        else
          @fusers_loan_types = Loan.where(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email, :created_at.lte => end_date, :created_at.gte => from_date).fields(:lending_type).all
        end
        if !@fusers_loan_types.blank?
          @fusers_loan_types.each do |floan_type|
            if !floan_type.lending_type.blank?
              if !@floan_types.include? "#{floan_type.lending_type}"
                @floan_types << "#{floan_type.lending_type}"
              end
            end
          end
        end

        @floan_type_array = Array.new
        if !@floan_types.blank?
          @floan_types.each do |floan_type|
            @ftype_hash = Hash.new
            if @adminLogin == true
              @ftype_loans = Loan.count(:delete.ne => 1, :delete_admin.ne => 1, :lending_type => "#{floan_type}", :created_at.lte => end_date, :created_at.gte => from_date)
            else
              @ftype_loans = Loan.count(:delete.ne => 1, :delete_broker.ne => 1, :email => @user_email, :lending_type => "#{floan_type}", :created_at.lte => end_date, :created_at.gte => from_date)
            end
            @ftype_hash['type'] = floan_type
            @ftype_hash['total'] = @ftype_loans
            @floan_type_array << @ftype_hash
          end
        end
      ###################End Loan Types #####################

      end
      @sub_brokers=Broker.count(:delete.ne => 1, :parent_user => current_user.id.to_s)
      @sub_brokers=Broker.count(:delete.ne => 1, :parent_user => current_user.id.to_s)
      users = User.where(:is_admin.ne => true).fields(:id).all
      @ids = Array.new
      users.each do |user|
        unless user.broker.blank?
          @ids << user.id
        end
      end
      @sub_users = @ids.count
      render partial: 'user_info'
      #################### End User Information ##########################
  end


  def net_amount
    
    @chart_type = params[:chart_type]

    unless params.blank?
      unless current_user.blank?
        check = UserChart.find_by_user_id("#{current_user.id}")
        if check.blank?
          info = UserChart.new
          info.user_id = current_user.id
          info.search_type = params[:range]
          info.chart_type_amount = params[:chart_type]  
          info.save
        else
          check.search_type = params[:range]
          check.chart_type_amount = params[:chart_type]
          check.save
        end

      end
    end
    # abort("#{@chart_type}")
    @user_email = current_user.email
    if params[:range] == "last_30_days"

        from_date = Time.now - 30.days
        end_date = Time.now

        current_year = end_date.strftime("%Y")
        @current_year = current_year.to_i
        @from_year = @current_year - 5
        
        # abort("#{from_year} -- #{current_year}")
        # @loans = Loan.where(:created_at.lte => end_date, :created_at.gte => from_date).fields(:net_loan_amount, :created_at).all
        # abort("#{@loans.inspect}")
        if @adminLogin == true
          @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
        else
          @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email).fields(:net_loan_amount).all
        end
        
        @amnt = 0
        @all_loans.each do |aloan|
          unless aloan.net_loan_amount.blank?
            @amnt = aloan.net_loan_amount + @amnt    
          end
        end
        
        @total_amnt = number_to_currency(@amnt)
        
        @bar_heading = "Net amount of last 30 days: #{@total_amnt}"
        
        from_date = Date.parse("#{from_date}")
        end_date = Date.parse("#{end_date}")
        all_dates = from_date..end_date
        # abort("#{all_dates.inspect}")
        @dates = Array.new
        @lloans = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          

          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{day} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%d %b, %Y")

          if @adminLogin == true
            @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
          else
            @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => fdate, :email =>@user_email).fields(:net_loan_amount, :created_at, :name).all
          end

          unless @loans.blank?
            @lloans << @loans.inspect
          end
          @lamnt = 0
          unless @loans.blank?
            @loans.each do |loan|
              unless loan.net_loan_amount.blank?
                @lamnt = loan.net_loan_amount + @lamnt    
              end
            end
          end
           # @total_lamnt = number_to_currency(@amnt)

          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @lamnt 
            @dates << data  
          # end
        end
        # abort("#{@lloans.inspect} -- #{@dates.inspect}")

    elsif params[:range] == "previous_month_record"
      last_month_date = Time.now - 1.month
      last_month = last_month_date.strftime("%m")
      year = last_month_date.strftime("%Y")
      
      from_date = "#{year}-#{last_month}-01"
      from_date = Date.parse("#{from_date} 00:00:00 UTC").strftime("%Y-%m-%d")
      
      days = Time.days_in_month(last_month.to_i, year.to_i)
      last_date = "#{year}-#{last_month}-#{days}"
      last_date = Date.parse("#{last_date} 00:00:00 UTC").strftime("%Y-%m-%d")
      
      # abort("#{from_date} - #{last_date}")
      start_date = from_date.to_time
      end_date = last_date.to_time
      # abort("#{from_date} -- #{last_date}")

      if @adminLogin == true
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => start_date).fields(:net_loan_amount).all
      else
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => start_date, :email =>@user_email).fields(:net_loan_amount).all
      end

      @amnt = 0
      @all_loans.each do |aloan|
        unless aloan.net_loan_amount.blank?
          @amnt = aloan.net_loan_amount + @amnt    
        end
      end
        
      @total_amnt = number_to_currency(@amnt)
      @bar_heading = "Net amount of last month: #{@total_amnt}"

      all_dates = from_date..last_date
      @dates = Array.new
      all_dates.each do |day|
        fdate = "#{day} 00:00:00"
        ldate = "#{day} 23:59:59"
        fdate = fdate.to_time
        ldate = ldate.to_time
        
        bar_date = fdate.strftime("%d %b, %Y")
        if @adminLogin == true
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
        else
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email =>@user_email).fields(:net_loan_amount, :created_at, :name).all
        end
        @lamnt = 0
        unless @loans.blank?
          @loans.each do |loan|
            unless loan.net_loan_amount.blank?
              @lamnt = loan.net_loan_amount + @lamnt    
            end
          end
        end
        # unless @loans.blank?
          data = Hash.new
          data['date'] = bar_date
          data['num'] = @lamnt 
          @dates << data  
        # end
      end
    elsif params[:range] == "last_week"
      last_week = Time.now - 1.week

      from_date = last_week.at_beginning_of_week
      end_date = last_week.at_end_of_week
      
      sfrom_date = Date.parse("#{from_date}")
      send_date = Date.parse("#{end_date}")

      if @adminLogin == true
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
      else
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email).fields(:net_loan_amount).all
      end

      @amnt = 0
      @all_loans.each do |aloan|
        unless aloan.net_loan_amount.blank?
          @amnt = aloan.net_loan_amount + @amnt    
        end
      end
      @total_amnt = number_to_currency(@amnt)
     
      all_dates = sfrom_date..send_date
      # abort("#{all_dates.inspect}")
      @bar_heading = "Number of submissions of last week: #{@total_amnt}"
      # abort("#{@bar_heading}")

      @dates = Array.new
      all_dates.each do |day|
        fdate = "#{day} 00:00:00"
        

        ldate = "#{day} 23:59:59"
        fdate = fdate.to_time
        ldate = ldate.to_time
        # abort("#{day} -- #{fdate} -- #{ldate}")
        
        bar_date = fdate.strftime("%d %b, %Y")
        if @adminLogin == true
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
        else
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email =>@user_email).fields(:net_loan_amount, :created_at, :name).all
        end
        @lamnt = 0
        unless @loans.blank?
          @loans.each do |loan|
            unless loan.net_loan_amount.blank?
              @lamnt = loan.net_loan_amount + @lamnt    
            end
          end
        end
        # unless @loans.blank?
          data = Hash.new
          data['date'] = bar_date
          data['num'] = @lamnt
          @dates << data  
        # end
      end
    elsif params[:range] == "last_year"
      last_year = Time.now - 1.year
      @last_yr =  last_year.strftime("%Y")

      from_date = last_year.at_beginning_of_year
      end_date = last_year.at_end_of_year
      
      
      if @adminLogin == true
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
      else
        @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email =>@user_email).fields(:net_loan_amount).all
      end

      @amnt = 0
      @all_loans.each do |aloan|
        unless aloan.net_loan_amount.blank?
          @amnt = aloan.net_loan_amount + @amnt    
        end
      end
      @total_amnt = number_to_currency(@amnt)

      @bar_heading = "Number of submissions of last year: #{@total_amnt}"
      
      from_date = Date.parse("#{from_date}")
      end_date = Date.parse("#{end_date}")

      all_months = 1..12
      # abort("#{all_dates.inspect}")
      @dates = Array.new
      
      all_months.each do |month|
        # from_date = Date.parse("201").strftime("%Y-%m-%d")
        num_of_days = Time.days_in_month(month.to_i, @last_yr.to_i)
        fdate = "#{@last_yr}-#{month}-1 00:00:00"
        ldate = "#{@last_yr}-#{month}-#{num_of_days} 23:59:59"
        fdate = fdate.to_time
        ldate = ldate.to_time
        # abort("#{num_of_days} -- #{fdate} -- #{ldate}")
        
        bar_date = fdate.strftime("%b, %Y")
        if @adminLogin == true
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
        else
          @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => fdate, :email =>@user_email).fields(:net_loan_amount, :created_at, :name).all
        end

        @lamnt = 0
        unless @loans.blank?
          @loans.each do |loan|
            unless loan.net_loan_amount.blank?
              @lamnt = loan.net_loan_amount + @lamnt    
            end
          end
        end
        # unless @loans.blank?
          data = Hash.new
          data['date'] = bar_date
          data['num'] = @lamnt 
          @dates << data  
        # end
      end
    end

    render partial: 'bar_amount'

  end

  def select_range

     @chart_type = params[:chart_type]

      @user_email = current_user.email
      unless params.blank?
        unless current_user.blank?
          check = UserChart.find_by_user_id("#{current_user.id}")
          if check.blank?
            info = UserChart.new
            info.user_id = current_user.id
            info.search_type = params[:range]
            info.chart_type_loan = params[:chart_type]  
            info.save
          else
            check.search_type = params[:range]
            check.chart_type_loan = params[:chart_type]
            check.save
          end

        end
      end

      if params[:range] == "previous_month_record"
        last_month_date = Time.now - 1.month
        last_month = last_month_date.strftime("%m")
        year = last_month_date.strftime("%Y")
        
        from_date = "#{year}-#{last_month}-01"
        from_date = Date.parse("#{from_date} 00:00:00 UTC").strftime("%Y-%m-%d")
        
        days = Time.days_in_month(last_month.to_i, year.to_i)
        last_date = "#{year}-#{last_month}-#{days}"
        last_date = Date.parse("#{last_date} 00:00:00 UTC").strftime("%Y-%m-%d")
        
        # abort("#{from_date} - #{last_date}")
        start_date = from_date.to_time
        end_date = last_date.to_time
        # abort("#{from_date} -- #{last_date}")

        if @adminLogin == true
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => start_date)
        else
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => start_date, :email => @user_email)
        end

        @bar_heading = "Number of submissions of last month: #{@all_loans}"
        all_dates = from_date..last_date
        @dates = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          
          bar_date = fdate.strftime("%d %b, %Y")
          if @adminLogin == true
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate)
          else
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email)
          end
          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @loans.count 
            @dates << data  
          # end
        end
      elsif params[:range] == "last_30_days" 
        from_date = Time.now - 30.days
        end_date = Time.now

        if @adminLogin == true
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date)
        else
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email)
        end

        @bar_heading = "Number of submissions of last 30 days: #{@all_loans}"
        from_date = Date.parse("#{from_date}")
        end_date = Date.parse("#{end_date}")
        all_dates = from_date..end_date
        # abort("#{all_dates.inspect}")
        @dates = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          

          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{day} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%d %b, %Y")
          if @adminLogin == true
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate)
          else
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email)
          end
          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @loans.count 
            @dates << data  
          # end
        end
      elsif params[:range] == "last_week"
        last_week = Time.now - 1.week

        from_date = last_week.at_beginning_of_week
        end_date = last_week.at_end_of_week
        sfrom_date = Date.parse("#{from_date}")
        send_date = Date.parse("#{end_date}")

        if @adminLogin == true
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date)
        else
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email)
        end
        
        all_dates = sfrom_date..send_date
         # abort("#{all_dates}")
        
        @bar_heading = "Number of submissions of last week: #{@all_loans}"
        # abort("#{@bar_heading}")

        @dates = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          

          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{day} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%d %b, %Y")
          if @adminLogin == true
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate)
          else
            @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email)
          end
          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @loans.count 
            @dates << data  
          # end
        end
      elsif params[:range] == "last_year"

        last_year = Time.now - 1.year
        @last_yr =  last_year.strftime("%Y")

        from_date = last_year.at_beginning_of_year
        end_date = last_year.at_end_of_year
        
        
        if @adminLogin == true
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date)
        else
          @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email)
        end

        @bar_heading = "Number of submissions of last year: #{@all_loans}"
        
        from_date = Date.parse("#{from_date}")
        end_date = Date.parse("#{end_date}")

        all_months = 1..12
        # abort("#{all_dates.inspect}")
        @dates = Array.new
        
        all_months.each do |month|
          # from_date = Date.parse("201").strftime("%Y-%m-%d")
          num_of_days = Time.days_in_month(month.to_i, @last_yr.to_i)
          fdate = "#{@last_yr}-#{month}-1 00:00:00"
          ldate = "#{@last_yr}-#{month}-#{num_of_days} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{num_of_days} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%b, %Y")
          if @adminLogin == true
            @loans = Loan.count(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate)
          else
            @loans = Loan.count(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email)
          end
          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @loans 
            @dates << data  
          # end
        end

      end
        
      render partial: 'bar_display'
  end

  def custom_form
    begin
      
      @chart_type = "#{params[:chart_type]}"
      @user_email = "#{current_user.email}"
      unless params.blank?

        unless current_user.blank?
          check = UserChart.find_by_user_id("#{current_user.id}")
          if check.blank?
            info = UserChart.new
            info.user_id = current_user.id
            info.search_type = "custom" 
            info.from_date = "#{params[:from_date]}"
            info.to_date = "#{params[:to_date]}"
            if params[:bar_chart] == "net_amount"
              info.chart_type_amount = "#{params[:chart_type]}"
            elsif params[:bar_chart] == "loan_submissions"
              info.chart_type_loan = "#{params[:chart_type]}"
            end
            info.lending_types = "#{params[:lending_types]}"
            info.transaction_type = "#{params[:transaction_type]}"
            info.states = "#{params[:states]}"
            info.min_amnt = "#{params[:min_amnt]}"
            info.max_amnt = "#{params[:max_amnt]}"
            info.min_estimated_val = "#{params[:min_estimated_val]}"
            info.max_estimated_val = "#{params[:max_estimated_val]}"
            info.save
          else
            check.search_type = "custom"
            check.from_date = "#{params[:from_date]}"
            check.to_date = "#{params[:to_date]}"
            if params[:bar_chart] == "net_amount"
              check.chart_type_amount = "#{params[:chart_type]}"
            elsif params[:bar_chart] == "loan_submissions"
              check.chart_type_loan = "#{params[:chart_type]}"
            end 

            check.lending_types = "#{params[:lending_types]}"
            check.transaction_type = "#{params[:transaction_type]}"
            check.states = "#{params[:states]}"
            check.min_amnt = "#{params[:min_amnt]}"
            check.max_amnt = "#{params[:max_amnt]}"
            check.min_estimated_val = "#{params[:min_estimated_val]}"
            check.max_estimated_val = "#{params[:max_estimated_val]}"
            check.save
          end

        end
      end



      if params[:bar_chart] == "net_amount"
        from_date = "#{params[:from_date]} 00:00:00"
        end_date = "#{params[:to_date]} 23:59:59"

        from_date = from_date.to_time
        end_date = end_date.to_time

        if from_date > end_date
          error = 1
        end

        show_from_date = Date.parse("#{from_date}").strftime("%d %b, %y")
        show_to_date = Date.parse("#{end_date}").strftime("%d %b, %y")

        ##################### Search with State #######################
        custom_search = Array.new
        state_loans = Array.new
        state_ids = Array.new
        i=0
        unless params[:states].blank?
          states = params[:states].split(',')
          states.each do |state|
            st = state.downcase
            if @adminLogin == true
             sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            else
             sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            end
            unless sloan.blank?
              state_loans << sloan
              sloan.each do |sln|
                state_ids<< sln.id
              end
            end
          end

          custom_search[i] = state_ids
          i = i+1
        end

       
        ##################### Search with State #######################

        ##################### Search with Lending Category #######################
        
        lending_loans = Array.new
        lending_ids = Array.new
        unless params[:lending_types].blank?
          if @adminLogin == true
            lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
          else
            lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
          end
            unless lloans.blank?
              lending_loans << lloans
              lloans.each do |lloan|
                lending_ids<< lloan.id
              end
            end
            custom_search[i] = lending_ids
            i = i+1
        end

        ##################### Search with Lending Category #######################
        ####################### Search with Transaction Type #####################

        transaction_loans = Array.new
        transaction_ids = Array.new
        unless params[:transaction_type].blank?
            if @adminLogin == true
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            else
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            end
            unless tloans.blank?
              transaction_loans << tloans
              tloans.each do |tloan|
                transaction_ids<<tloan.id
              end
            end
            custom_search[i] = transaction_ids
            i = i+1
        end
        
        ####################### Search with Transaction Type #####################

         ###################### Search Estimated Value ############################

        estimated_loans = Array.new
        estimated_ids = Array.new

        if !params[:min_estimated_val].blank? || !params[:max_estimated_val].blank?
          if !params[:min_estimated_val].blank? && !params[:max_estimated_val].blank?
            min_val = params[:min_estimated_val].to_i
            max_val = params[:max_estimated_val].to_i
            if @adminLogin == true
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
            else
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
            end
          elsif !params[:min_estimated_val].blank?
            min_val = params[:min_estimated_val].to_i
            if @adminLogin == true
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
            else
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
            end
          elsif !params[:max_estimated_val].blank?
            max_val = params[:max_estimated_val].to_i
            if @adminLogin == true
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
            else
              eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
            end
          end

          unless eloans.blank?
            estimated_loans << eloans
            eloans.each do |eloan|
              estimated_ids << eloan.id
            end
          end
          custom_search[i] = estimated_ids
          i = i+1
        end
            
            

        ###################### End Search Estimated Value ########################
         ##################### Search Net Loan Amount ############################

          netamnt_loans = Array.new
          netamnt_ids = Array.new

          if !params[:min_amnt].blank? || !params[:max_amnt].blank?
            if !params[:min_amnt].blank? && !params[:max_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:min_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:max_amnt].blank?
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              end
            end
            unless aloans.blank?
              netamnt_loans << aloans
              aloans.each do |aloan|
                netamnt_ids << aloan.id
              end
            end
            custom_search[i] = netamnt_ids
            i = i+1
          end
        ##################### Search Net Loan Amount ############################

        # abort("#{custom_search.inspect}")

        # if !params[:states].blank? || !params[:lending_types].blank? || !params[:transaction_type].blank?
        #   @ids = Array.new
        #   if !lending_ids.blank? && !state_ids.blank? 
        #     @ids = lending_ids & state_ids
        #   elsif !lending_ids.blank?
        #     @ids = lending_ids
        #   elsif !state_ids.blank?
        #     @ids = state_ids
        #   end
        # end
        
        
        if !params[:states].blank? || !params[:lending_types].blank? || !params[:transaction_type].blank?
          @num_arr = custom_search.count
          @final_arr = custom_search
          # abort("#{@final_arr.inspect}")
          @ids = Array.new
          if @num_arr == 1
            @ids = @final_arr[0]
          elsif  @num_arr == 2
            @ids = @final_arr[0] & @final_arr[1]
          elsif @num_arr == 3
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2]
          elsif @num_arr == 4
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3]
          elsif @num_arr == 5
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3] & @final_arr[4]
          end
        end

            
            

        if defined? @ids
          if @adminLogin == true
            @all_loans = Loan.where(:id=>@ids, :created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
          else
            @all_loans = Loan.where(:id=>@ids, :created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email).fields(:net_loan_amount).all
          end
        else
          if @adminLogin == true
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
          else
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email).fields(:net_loan_amount).all
          end
        end

        @amnt = 0
        @all_loans.each do |aloan|
          unless aloan.net_loan_amount.blank?
            @amnt = aloan.net_loan_amount + @amnt    
          end
        end
        @total_amnt = number_to_currency(@amnt)
        
        

        from_date = Date.parse("#{params[:from_date]}")
        end_date = Date.parse("#{params[:to_date]}")

        @bar_heading = "Net amount from #{show_from_date} to #{show_to_date} : #{@total_amnt}"
       
        all_dates = from_date..end_date
        # abort("#{all_dates.inspect}")
        @dates = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          

          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{day} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%d %b, %Y")

          if defined? @ids
            if @adminLogin == true
              @loans = Loan.where(:id=>@ids, :created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
            else
              @loans = Loan.where(:id=>@ids, :created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email).fields(:net_loan_amount, :created_at, :name).all
            end
          else
            if @adminLogin == true
              @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate).fields(:net_loan_amount, :created_at, :name).all
            else
              @loans = Loan.where(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email).fields(:net_loan_amount, :created_at, :name).all
            end
          end
  # abort("Ids-#{@ids.inspect}----FinalArr-#{@final_arr.inspect}")
          
          @lamnt = 0
          unless @loans.blank?
            @loans.each do |loan|
              unless loan.net_loan_amount.blank?
                @lamnt = loan.net_loan_amount + @lamnt    
              end
            end
          end

          unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @lamnt 
            @dates << data  
          end
        end

        # abort("#{@dates.inspect}")
      else
        from_date = "#{params[:from_date]} 00:00:00"
        end_date = "#{params[:to_date]} 23:59:59"
        from_date = from_date.to_time
        end_date = end_date.to_time
        if from_date > end_date
          error = 1
        end
        show_from_date = Date.parse("#{from_date}").strftime("%d %b, %y")
        show_to_date = Date.parse("#{end_date}").strftime("%d %b, %y")

       ##################### Search with State #######################
        custom_search = Array.new
        state_loans = Array.new
        state_ids = Array.new
        i = 0
        unless params[:states].blank?
          states = params[:states].split(',')
          states.each do |state|
            st = state.downcase
            if @adminLogin == true
              sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            else
              sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            end
            unless sloan.blank?
              state_loans << sloan
              sloan.each do |sln|
                state_ids<< sln.id
              end
            end
          end
          custom_search[i] = state_ids
          i = i+1
        end

        # abort("#{state_ids.inspect}")
        ##################### Search with State #######################

        ##################### Search with Lending Category #######################
        
        lending_loans = Array.new
        lending_ids = Array.new
        unless params[:lending_types].blank?
            if @adminLogin == true
              lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
            else
              lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
            end

            unless lloans.blank?
              lending_loans << lloans
              lloans.each do |lloan|
                lending_ids<< lloan.id
              end
            end
            custom_search[i] = lending_ids
            i = i+1
        end
        

        # abort("#{lending_ids.inspect}")
        ##################### Search with Lending Category #######################
        
        ####################### Search with Transaction Type #####################

        transaction_loans = Array.new
        transaction_ids = Array.new
        unless params[:transaction_type].blank?
            if @adminLogin == true
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,:delete_admin.ne => 1,  :created_at.gte => from_date, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            else
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            end
            unless tloans.blank?
              transaction_loans << tloans
              tloans.each do |tloan|
                transaction_ids<<tloan.id
              end
            end
            custom_search[i] = transaction_ids
            i = i+1
        end
        
        ####################### Search with Transaction Type #####################

        ###################### Search Estimated Value ############################

        estimated_loans = Array.new
        estimated_ids = Array.new

        if !params[:min_estimated_val].blank? || !params[:max_estimated_val].blank?
          if !params[:min_estimated_val].blank? && !params[:max_estimated_val].blank?
           min_val = params[:min_estimated_val].to_i
           max_val = params[:max_estimated_val].to_i
          if @adminLogin == true
           eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date,  :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
          else
           eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
          end
          elsif !params[:min_estimated_val].blank?
           min_val = params[:min_estimated_val].to_i
           if @adminLogin == true
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           else
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           end
          elsif !params[:max_estimated_val].blank?
           max_val = params[:max_estimated_val].to_i
           if @adminLogin == true
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
           else
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
           end
          end

          unless eloans.blank?
            estimated_loans << eloans
            eloans.each do |eloan|
              estimated_ids << eloan.id
            end
          end
          custom_search[i] = estimated_ids
          i = i+1
        end
            
            

        ###################### End Search Estimated Value ########################

        ##################### Search Net Loan Amount ############################

          netamnt_loans = Array.new
          netamnt_ids = Array.new

          if !params[:min_amnt].blank? || !params[:max_amnt].blank?
            if !params[:min_amnt].blank? && !params[:max_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:min_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:max_amnt].blank?
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              end
            end

            unless aloans.blank?
              netamnt_loans << aloans
              aloans.each do |aloan|
                netamnt_ids << aloan.id
              end
            end
            custom_search[i] = netamnt_ids
            i = i+1
          
          end
        ##################### Search Net Loan Amount ############################
        
        # if !params[:states].blank? || !params[:lending_types].blank? 
        #   @ids = Array.new
        #   if !lending_ids.blank? && !state_ids.blank?
        #     @ids = lending_ids & state_ids
        #   elsif !lending_ids.blank?
        #     @ids = lending_ids
        #   elsif !state_ids.blank?
        #     @ids = state_ids
        #   end
        # end
        # abort("#{ids.inspect}")    
       
        # abort("#{@final_arr.inspect}")
        if !params[:states].blank? || !params[:lending_types].blank? || !params[:transaction_type].blank?
          @num_arr = custom_search.count
          @final_arr = custom_search
          @ids = Array.new
          if @num_arr == 1
            @ids = @final_arr[0]
          elsif  @num_arr == 2
            @ids = @final_arr[0] & @final_arr[1]
          elsif @num_arr == 3
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2]
          elsif @num_arr == 4
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3]
          elsif @num_arr == 5
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3] & @final_arr[4]
          end
        end
            
          
        if defined? @ids
          @all_loans = @ids.count
        else
          if @adminLogin == true
            @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date)
          else
            @all_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email)
          end
        end
        
        @bar_heading = "Number of submissions from #{show_from_date} to #{show_to_date} : #{@all_loans}"
        from_date = Date.parse("#{params[:from_date]}")
        end_date = Date.parse("#{params[:to_date]}")
        # abort("#{from_date} -- #{end_date}")
        all_dates = from_date..end_date
        # abort("#{all_dates.inspect}")
        @dates = Array.new
        all_dates.each do |day|
          fdate = "#{day} 00:00:00"
          

          ldate = "#{day} 23:59:59"
          fdate = fdate.to_time
          ldate = ldate.to_time
          # abort("#{day} -- #{fdate} -- #{ldate}")
          
          bar_date = fdate.strftime("%d %b, %Y")
          if defined? @ids
            if @adminLogin == true
              @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate, :id=>@ids)
            else
              @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email, :id=>@ids)
            end
          else
            
            if @adminLogin == true
              @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => fdate)
            else
              @loans = Loan.all(:created_at.lte => ldate, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => fdate, :email => @user_email)
            end
          end

          # unless @loans.blank?
            data = Hash.new
            data['date'] = bar_date
            data['num'] = @loans.count 
            @dates << data  
          # end
        end
      end

      rescue Exception => exc
      if exc.message
        error = 1
      end
    end
    if params[:bar_chart] == "net_amount"
      @render_page = "bar_amount"
    else
      @render_page = "bar_display"
    end

    if error == 1
      render plain: "error"
    else
      render partial: "#{@render_page}"
    end
    
  end 

  def custom_search

        @user_email = current_user.email

        from_date = "#{params[:from_date]} 00:00:00"
        end_date = "#{params[:to_date]} 23:59:59"

        from_date = from_date.to_time
        end_date = end_date.to_time

        if from_date > end_date
          error = 1
        end

        show_from_date = Date.parse("#{from_date}").strftime("%d %b, %y")
        show_to_date = Date.parse("#{end_date}").strftime("%d %b, %y")
        ##################### Search with State #######################
        custom_search = Array.new
        state_loans = Array.new
        state_ids = Array.new
        i=0
        unless params[:states].blank?
          states = params[:states].split(',')
          states.each do |state|
            st = state.downcase
            if @adminLogin == true
              sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            else
              sloan = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :loan_state => "#{st}").fields(:loan_state, :created_at).all
            end
            unless sloan.blank?
              state_loans << sloan
              sloan.each do |sln|
                state_ids<< sln.id
              end
            end
          end

          custom_search[i] = state_ids
          i = i+1
        end

       
        ##################### Search with State #######################

        ##################### Search with Lending Category #######################
        
        lending_loans = Array.new
        lending_ids = Array.new
        unless params[:lending_types].blank?
            if @adminLogin == true
              lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
            else
              lloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :lending_type => "#{params[:lending_types]}").fields(:lending_type, :created_at).all
            end
            unless lloans.blank?
              lending_loans << lloans
              lloans.each do |lloan|
                lending_ids<< lloan.id
              end
            end
            custom_search[i] = lending_ids
            i = i+1
        end

        ##################### Search with Lending Category #######################
        ####################### Search with Transaction Type #####################

        transaction_loans = Array.new
        transaction_ids = Array.new
        unless params[:transaction_type].blank?
            if @adminLogin == true
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            else
              tloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :transaction_type => "#{params[:transaction_type]}").fields(:transaction_type, :created_at).all
            end
            unless tloans.blank?
              transaction_loans << tloans
              tloans.each do |tloan|
                transaction_ids<<tloan.id
              end
            end
            custom_search[i] = transaction_ids
            i = i+1
        end
        
        ####################### Search with Transaction Type #####################
         ###################### Search Estimated Value ############################

        estimated_loans = Array.new
        estimated_ids = Array.new

        if !params[:min_estimated_val].blank? || !params[:max_estimated_val].blank?
          if !params[:min_estimated_val].blank? && !params[:max_estimated_val].blank?
           min_val = params[:min_estimated_val].to_i
           max_val = params[:max_estimated_val].to_i
           if @adminLogin == true
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           else
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           end
          elsif !params[:min_estimated_val].blank?
           min_val = params[:min_estimated_val].to_i
           if @adminLogin == true
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           else
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.gte => min_val).fields(:estimated_value, :created_at).all
           end
          elsif !params[:max_estimated_val].blank?
           max_val = params[:max_estimated_val].to_i
           if @adminLogin == true
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
           else
            eloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :estimated_value.lte => max_val).fields(:estimated_value, :created_at).all
           end
          end

          unless eloans.blank?
            estimated_loans << eloans
            eloans.each do |eloan|
              estimated_ids << eloan.id
            end
          end
          custom_search[i] = estimated_ids
          i = i+1
        end
            
            

        ###################### End Search Estimated Value ########################

        ##################### Search Net Loan Amount ############################

          netamnt_loans = Array.new
          netamnt_ids = Array.new

          if !params[:min_amnt].blank? || !params[:max_amnt].blank?
            if !params[:min_amnt].blank? && !params[:max_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:min_amnt].blank?
              min_amnt = params[:min_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.gte => min_amnt).fields(:net_loan_amount, :created_at).all
              end
            elsif !params[:max_amnt].blank?
              max_amnt = params[:max_amnt].to_i
              if @adminLogin == true
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,:delete_admin.ne => 1,  :created_at.gte => from_date, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              else
                aloans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :created_at.gte => from_date, :email => @user_email, :net_loan_amount.lte => max_amnt).fields(:net_loan_amount, :created_at).all
              end
            end
            unless aloans.blank?
              netamnt_loans << aloans
              aloans.each do |aloan|
                netamnt_ids << aloan.id
              end
            end
            custom_search[i] = netamnt_ids
            i = i+1
          end
        ##################### Search Net Loan Amount ############################

        if !params[:states].blank? || !params[:lending_types].blank? || !params[:transaction_type].blank?
          @num_arr = custom_search.count
          @final_arr = custom_search
          @ids = Array.new
          if @num_arr == 1
            @ids = @final_arr[0]
          elsif  @num_arr == 2
            @ids = @final_arr[0] & @final_arr[1]
          elsif @num_arr == 3
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2]
          elsif @num_arr == 4
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3]
          elsif @num_arr == 5
            @ids = @final_arr[0] & @final_arr[1] & @final_arr[2] & @final_arr[3] & @final_arr[4]
          end
          if @adminLogin == true
            @all_loans = Loan.where(:id => @ids, :created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
          else
            @all_loans = Loan.where(:id => @ids, :created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date, :email => @user_email).fields(:net_loan_amount).all
          end
          @num_of_loans = @ids.count
        else
          
          if @adminLogin == true
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1,  :delete_admin.ne => 1,  :created_at.gte => from_date).fields(:net_loan_amount).all
            @num_of_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1,:created_at.gte => from_date)
          else
            @all_loans = Loan.where(:created_at.lte => end_date, :delete.ne => 1, :delete_admin.ne => 1,  :created_at.gte => from_date, :email => @user_email).fields(:net_loan_amount).all
            @num_of_loans = Loan.count(:created_at.lte => end_date, :delete.ne => 1, :delete_broker.ne => 1, :created_at.gte => from_date, :email => @user_email)
          end
        end

       
        
        @amnt = 0
        @all_loans.each do |aloan|
          unless aloan.net_loan_amount.blank?
            @amnt = aloan.net_loan_amount + @amnt    
          end
        end
        info = Hash.new
        info['total_amnt'] = number_to_currency(@amnt)
        info['num_of_loan'] = @num_of_loans

        render json:info.to_json
  end


  ################ End Dashboard #########################
  def broker_check
  end
  
  def test
    @contact = Infusionsoft.data_load('Contact', 925, [:FirstName, :LastName])
  end

  def sign_up

   
    @current_year = Date.today.strftime("%Y")
    @plan = params[:plan]
    @pInfo = Plan.find_by_plan_id(params[:plan])
    @plans = Plan.all

    unless current_user.blank?
      redirect_to controller:"loans"
    end
  end

  def lender_sign_up

    # plan = Plan.new
    # plan.plan_id = "lender_plan"
    # plan.name = "Lender"
    # plan.amount = "50000"
    # plan.currency = "usd"
    # plan.interval = "month"
    # plan.save
   
    @current_year = Date.today.strftime("%Y")
    @plan = "lender_plan"
    @pInfo = Plan.find_by_plan_id("lender_plan")
    @plans = Plan.all

    unless current_user.blank?
      redirect_to controller:"loans"
    end
  end

  def create_broker

    # abort("#{params.inspect}")

    # unless params[:stripeToken].blank?
    #   require "stripe"
    #   Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"

    #   broker = Stripe::Customer.create(
    #     :description => "Brokers",
    #     :source => params[:stripeToken],
    #     :email => params[:email],
    #     :plan => params[:plan]
    #   )


    #  end

   
  # subscription = Recurly::Subscription.create! plan_code: 'business',
  # account: {
  #   account_code: 'pat_smith',
  #   billing_info: { token_id: "#{params[:recurlytoken]}" }
  # }
  user = User.new
  uname = "#{params[:firstName]} #{params[:lastName]}"
  user.name = uname.camelize
  user.email = params[:email]
  usrname = params[:username].downcase
  user.username = usrname.gsub(' ','')
  uname = usrname.gsub(' ','')
  sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
  user.subdomain = sub_domain
  user.password = params[:password]
  @roles = Array.new
  @roles.push(Role.new(:name=>'Broker'))
  user.roles = @roles
  plan = params[:plan].downcase
  unless params[:recurlytoken].blank?
    subscription = Recurly::Subscription.create(
    :plan_code => "#{plan}",
    :currency  => 'USD',
    :customer_notes  => 'Thank you for your business!',
    :account   => {
      :account_code => "#{user.id}",
      :email        => "#{params[:email]}",
      :first_name   => "#{params[:firstName]}",
      :last_name    => "#{params[:lastName]}",
      billing_info: { token_id: "#{params[:recurlytoken]}" }
    }
    )
  end
  
  # account = Recurly::Account.create(
  # :account_code => '1',
  # :email        => 'verena@example.com',
  # :first_name   => 'Verena',
  # :last_name    => 'Example'
  # )

  # abort("#{subscription.inspect}")


    
    unless params[:recurlytoken].blank?
        user.subscription_id = subscription.uuid
        user.with_recurly = 1
    end
    user.plan = params[:plan]
    if params[:plan]=="free"
      user.plan = "free"
      user.max_users = "1"
      user.max_lenders = "5"
      user.max_storage = "1GB"
      user.max_upload = "10MB"
      user.pipelines = 0
      user.req_docs = 0
      user.loan_application_links = 0
      user.forward_email = 0
    elsif params[:plan]=="BUSINESS"
      user.plan = "business"
      user.max_users = "5"
      user.max_lenders = "No Limit"
      user.max_storage = "5GB"
      user.max_upload = "25MB"
      user.pipelines = 1
      user.req_docs = 1
      user.loan_application_links = 0
      user.forward_email = 0
    
    elsif params[:plan]=="ENTERPRISE"
      user.plan = "enterprise"
      user.max_users = "15"
      user.max_lenders = "No Limit"
      user.max_storage = "100GB"
      user.max_upload = "No File Cap"
      
      unless user.name.blank?
        uname = user.name.downcase
      else 
        uname = "user"
      end
      time_now = Time.now.strftime("%m%d%y%H%M%S")
      sys_email = "#{uname}#{time_now}@idealview.us"
      user.system_email = "#{sys_email}"

      user.pipelines = 1
      user.req_docs = 1
      user.loan_application_links = 1
      user.forward_email = 1
    end    
    #abort("#{user.inspect}")
    user.save

    brokr = Broker.new
    brokr.firstName = params[:firstName]
    brokr.lastName = params[:lastName] 
    brokr.name = "#{params[:firstName]} #{params[:lastName]}"
    unless params[:company].blank?
      brokr.company = params[:company]
    end
    unless params[:jobTitle].blank?
      brokr.jobTitle = params[:jobTitle]
    end
    unless params[:streetAddress1].blank?
      brokr.streetAddress1 = params[:streetAddress1]
    end
    unless params[:city].blank?
      brokr.city = params[:city]
    end
    unless params[:state].blank?
      brokr.state = params[:state]
    end
    unless params[:postalCode].blank?
      brokr.postalCode = params[:postalCode]
    end
    unless params[:stripeToken].blank?
      brokr.customer_id = broker.id
    end
    brokr.plan = params[:plan]
    brokr.email = params[:email]
    brokr.password = params[:password]
    brokr.save
    # LoanUrlMailer.welcome_email(brokr.id).deliver
    # flash[:messages] = "Your account is created successfully"  
    # redirect_to :action => 'index', :id => 'success'

    pass = "1dealv1ew"
    femail = AESCrypt.encrypt("#{params[:email]}", pass)
    fpass = AESCrypt.encrypt("#{params[:password]}", pass)
    redirect_to :action => "funding_login", :a => femail, :b => fpass

  end

  def create_lender

    isBroker = params[:broker]
    user = User.new
    uname = "#{params[:firstName]} #{params[:lastName]}"
    user.name = uname.camelize
    user.email = params[:email]
    usrname = params[:username].downcase
    user.username = usrname.gsub(' ','')
    uname = usrname.gsub(' ','')
    sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
    user.subdomain = sub_domain
    user.password = params[:password]
    @roles = Array.new
    @roles.push(Role.new(:name=>'Lender'))
    user.roles = @roles
    plan = params[:plan].downcase
    unless params[:recurlytoken].blank?
      subscription = Recurly::Subscription.create(
      :plan_code => "#{plan}",
      :currency  => 'USD',
      :customer_notes  => 'Thank you for your business!',
      :account   => {
        :account_code => "#{user.id}",
        :email        => "#{params[:email]}",
        :first_name   => "#{params[:firstName]}",
        :last_name    => "#{params[:lastName]}",
        billing_info: { token_id: "#{params[:recurlytoken]}" }
      }
      )
    end
    
    # account = Recurly::Account.create(
    # :account_code => '1',
    # :email        => 'verena@example.com',
    # :first_name   => 'Verena',
    # :last_name    => 'Example'
    # )

    # abort("#{subscription.inspect}")


      
      unless params[:recurlytoken].blank?
          user.subscription_id = subscription.uuid
          user.with_recurly = 1
      end
      user.plan = "lender"
      user.market_access = 1
      user.save

       params[:ContactType] = "Lender"
        unless params[:_LendingTypes].blank?
          params[:_LendingTypes] = params[:_LendingTypes].join(",")
        end
        unless params[:_BusinessFinancingTypes].blank?
          params[:_BusinessFinancingTypes] = params[:_BusinessFinancingTypes].join(",")
        end
        unless params[:_EquityandCrowdFunding].blank?
          params[:_EquityandCrowdFunding] = params[:_EquityandCrowdFunding].join(",")
        end
        unless params[:_MortageTypes].blank?
          params[:_MortageTypes] = params[:_MortageTypes].join(",")
        end
        unless params[:_LendingStates0].blank?
          params[:_LendingStates0] = params[:_LendingStates0].join(",")
        end
        #abort("#{params[:_LendingTypes].inspect}")
        #infusion_id = Infusionsoft.contact_add(params)
        #if_tag = Infusionsoft.contact_add_to_group(infusion_id,244) 
        db = Lender.new()
        #db.infusion_id = infusion_id
        db.firstName = params['firstName']
        db.broker = isBroker  
        db.lastName = params['lastName']
        db.name = params['firstName']+' '+params['lastName']
        db.company = params['Company']
        db.jobTitle = params['JobTitle']
        db.streetAddress1 = params['StreetAddress1']
        db.city = params['city']
        db.state = params['state']
        db.postalCode = params['postalCode']
        db.email = params['email']
        db.loanMinDropDown = params['_LoanMinDropDown']
        db.loanMaxDropDown = params['_LoanMaxDropDown']
        db.pointsMin = params['_PointsMin']
        db.pointsMax = params['_PointsMax']
        db.interestRateMax = params['_InterestRateMax']
        db.interestRateMin = params['_InterestRateMin']
        db.termLengthMin = params['_TermLengthMin']
        db.termLengthMax = params['_TermLengthMax']
        db.termLengthType = params['_TermLengthType']
        db.capitalizationStructure0 = params['_CapitalizationStructure0']
        db.timeInBusiness = params['_TimeInBusiness']
        db.lendingStates0 = params['_LendingStates0']
        db.otherLendingPreferences = params['_OtherLendingPreferences']
        db.loanToValueMin = params['_LoanToValueMin']
        db.loanToValueMax = params['_LoanToValueMax']
        db.lendingCategory = params['_LendingCategory']
        db.lendingTypes = params['_LendingTypes']
        db.businessFinancingTypes = params['_BusinessFinancingTypes']
        db.equityandCrowdFunding = params['_EquityandCrowdFunding']
        db.mortageTypes = params['_MortageTypes']
        db.save


         db = Broker.new
        db.firstName = params['firstName']
        db.plan = "lender"
        db.lastName = params['lastName']
        db.name = params['firstName']+' '+params['lastName']
        db.company = params['Company']
        db.jobTitle = params['JobTitle']
        db.streetAddress1 = params['StreetAddress1']
        db.city = params['city']
        db.state = params['state']
        db.postalCode = params['postalCode']
        db.email = params['email']
        db.password = params['password']
        db.lender = 1
        db.save

        LoanUrlMailer.email_lender(db).deliver
      # LoanUrlMailer.welcome_email(brokr.id).deliver
      # flash[:messages] = "Your account is created successfully"  
      # redirect_to :action => 'index', :id => 'success'

      pass = "1dealv1ew"
      femail = AESCrypt.encrypt("#{params[:email]}", pass)
      fpass = AESCrypt.encrypt("#{params[:password]}", pass)
      redirect_to :action => "funding_login", :a => femail, :b => fpass

  end


  def checkemail
  	user = User.find_by_email(params[:email])
  	if user.blank?
  		render plain: 'true'
  	else
  		render plain: 'false'
  	end
  end

  def checkuname
    usrname = params[:username].downcase
    uname = usrname.gsub(' ','')
    user = User.find_by_username("#{uname}")
    if user.blank?
      render plain: 'true'
    else
      render plain: 'false'
    end
  end

  def login
      authorized_user = User.authenticate(params[:email],params[:password])
      if authorized_user
        session[:user_id] = authorized_user.id
        session[:current_user] = authorized_user
        @current_user = authorized_user

        uInfo  = User.find_by_email("#{current_user.email}")
        flash[:notice] = "Wow Welcome again, you logged in as #{authorized_user.email}"
        redirect_to(:controller => 'loans', :action => 'index')
      else
        flash[:notice] = "Invalid Username or Password"
        flash[:color]= "invalid"
        render "login"  
      end
  end

   def create_coupon
    # abort("sfgs")
   
    
      # coupon = Recurly::Coupon.new(
      #   :coupon_code    => 'DIScount50',
      #   :redeem_by_date => Date.new(2014, 1, 1),
      #   :duration     => 'single_use',
      #   :name => "Special Discount-Offer",
      #   :coupon_type => "single_code",
      #   :discount_type => "#{params[:discount_type]}",
      #   :discount_percent => "#{params[:percentage]}",
      #   :discount_in_cents => "#{params[:dollars]}",
      #   :duration => "#{params[:duration]}",
      #   :temporal_amount => "#{params[:temporal_amount]}",
      #   :temporal_unit => params[:temporal_unit],
      #   :max_redemptions => params[:max_redemptions],
      #   :applies_to_all_plans => true,
      #   :redemption_resource => "account"

      # )
      @cupn = Array.new
      Recurly::Coupon.find_each do |coupon|
        @cupn << "Coupon: #{coupon.inspect}"
      end
      abort("#{@cupn.inspect}")

      #  coupon = Recurly::Coupon.new(
      #   :coupon_code    => 'DIScount50',
      #   :name => "Special Discount-Offer",
      #   :discount_type => "percent",
      #   :discount_percent => 30,
        
      # )
       # coupon.save
      abort("#{coupon.inspect}")
    end

  def login_page
    # crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    pass = "1dealv1ew"
    femail = AESCrypt.encrypt("#{params[:email]}", pass)
    fpass = AESCrypt.encrypt("#{params[:password]}", pass)
    redirect_to :action => "funding_login", :a => femail, :b => fpass
  end

  def funding_login
    pass = "1dealv1ew"
    @email = AESCrypt.decrypt("#{params[:a]}", pass)
    @password = AESCrypt.decrypt("#{params[:b]}", pass)
  end

  def cpc_login_page
    # crypt = ActiveSupport::MessageEncryptor.new(Rails.configuration.secret_key_base)
    uInfo = User.find_by_id("#{params[:token]}")
    @email = uInfo.email
    @password = uInfo.user_password
  end

  def cpc_login
    pass = "1dealv1ew"
    @email = AESCrypt.decrypt("#{params[:a]}", pass)
    @password = AESCrypt.decrypt("#{params[:b]}", pass)
  end

  def save_val
    session[:password] = params[:val] 
    render text: "done"
  end

  def logout
    redirect_to "https://idealview.us/?action=signout"
  end

  def idv_login


    resource = User.find_for_database_authentication(:email => params[:user_login][:email])
    # abort("#{resource.inspect}")
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user_login][:password])
      uInfo = User.find_by_id(resource.id)
      unless uInfo.blank?
        uInfo.user_password = "#{params[:user_login][:password]}"
        uInfo.name = "Kellen"
        uInfo.save
      end
      sign_in(:user, resource)
      # resource.id!

      uInfoz = User.find_by_id("54d27078dba1d60c3f000003")
       abort("#{uInfoz.inspect}")
      render :json=> {:id=>resource.id, :email=>resource.email}, :status => :ok
      return
    end
    invalid_login_attempt
  end




   protected
  def ensure_params_exist 
  return unless params[:user_login].blank?
    render :json=>{:message=>"missing user_login parameter"}, :status=>422
  end
  def invalid_login_attempt
    render :json=> {:message=>"Error with your login or password"}, :status=>401
  end

 

end
