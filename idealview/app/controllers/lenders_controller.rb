class LendersController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def index_m
    
    @infusion_lenders = Infusionsoft.data_query('Contact',1000,0,{:ContactType=>'Lender'},Lender.highlight_fields)
    #abort("#{@infusion_lenders}")
    @lender_id=Array.new
    @infusion_lenders.each_with_index do |lender, i|
        unless lender['_LoanMinDropDown'].blank?
          already=Lender.find_by_infusion_id(lender['Id'])
          unless already.blank?
            already.id = already.id
            already.firstName = lender['FirstName'] 
            already.lastName = lender['LastName']
            already.name = lender['FirstName']+' '+lender['LastName']
            already.company = lender['Company']
            already.jobTitle = lender['JobTitle']
            already.streetAddress1 = lender['StreetAddress1']
            already.streetAddress2 = lender['StreetAddress2']
            already.city = lender['City']
            already.state = lender['State']
            already.postalCode = lender['PostalCode']
            already.country = lender['Country']
            already.phone1 = lender['Phone1']
            already.phone2 = lender['Phone2']
            already.fax1 = lender['Fax1']
            already.email = lender['Email']
            already.website = lender['Website']
            already.address2Street1 = lender['Address2Street1']
            already.address2Street2 = lender['Address2Street2']
            already.city2 = lender['City2']
            already.state2 = lender['State2']
            already.postalCode2 = lender['PostalCode2']
            already.country2 = lender['Country2']
            already.address3Street1 = lender['Address3Street1']
            already.address3Street2 = lender['Address3Street2']
            already.city3 = lender['City3']
            already.state3 = lender['State3']
            already.postalCode3 = lender['PostalCode3']
            already.country3 = lender['Country3']
            already.numberOfClosedDeals = lender['_NumberOfClosedDeals']
            already.fDRanking = lender['_FDRanking']
            already.loanMinDropDown = lender['_LoanMinDropDown']
            already.loanMaxDropDown = lender['_LoanMaxDropDown']
            already.pointsMin = lender['_PointsMin']
            already.pointsMax = lender['_PointsMax']
            already.interestRateMax = lender['_InterestRateMax']
            already.termLengthMin = lender['_TermLengthMin']
            already.termLengthMax = lender['_TermLengthMax']
            already.termLengthType = lender['_TermLengthType']
            already.capitalizationStructure0 = lender['_CapitalizationStructure0']
            already.timeInBusiness = lender['_TimeInBusiness']
            already.lendingStates0 = lender['_LendingStates0']
            already.timeInBusiness = lender['_TimeInBusiness']
            already.otherLendingPreferences = lender['_OtherLendingPreferences']
            already.loanToValueMin = lender['_LoanToValueMin']
            already.loanToValueMax = lender['_LoanToValueMax']
            already.lendingCountries = lender['_LendingCountries']
            already.lendingCategory = lender['_LendingCategory']
            already.lendingTypes = lender['_LendingTypes']
            already.businessFinancingTypes = lender['_BusinessFinancingTypes']
            already.equityandCrowdFunding = lender['_EquityandCrowdFunding']
            already.mortageTypes = lender['_MortageTypes']
            already.save
          else
            db = Lender.new()
            db.infusion_id = lender['Id']
            db.firstName = lender['FirstName'] 
            db.lastName = lender['LastName']
            db.name = lender['FirstName']+' '+lender['LastName']
            db.company = lender['Company']
            db.jobTitle = lender['JobTitle']
            db.streetAddress1 = lender['StreetAddress1']
            db.streetAddress2 = lender['StreetAddress2']
            db.city = lender['City']
            db.state = lender['State']
            db.postalCode = lender['PostalCode']
            db.country = lender['Country']
            db.phone1 = lender['Phone1']
            db.phone2 = lender['Phone2']
            db.fax1 = lender['Fax1']
            db.email = lender['Email']
            db.website = lender['Website']
            db.address2Street1 = lender['Address2Street1']
            db.address2Street2 = lender['Address2Street2']
            db.city2 = lender['City2']
            db.state2 = lender['State2']
            db.postalCode2 = lender['PostalCode2']
            db.country2 = lender['Country2']
            db.address3Street1 = lender['Address3Street1']
            db.address3Street2 = lender['Address3Street2']
            db.city3 = lender['City3']
            db.state3 = lender['State3']
            db.postalCode3 = lender['PostalCode3']
            db.country3 = lender['Country3']
            db.numberOfClosedDeals = lender['_NumberOfClosedDeals']
            db.fDRanking = lender['_FDRanking']
            db.loanMinDropDown = lender['_LoanMinDropDown']
            db.loanMaxDropDown = lender['_LoanMaxDropDown']
            db.pointsMin = lender['_PointsMin']
            db.pointsMax = lender['_PointsMax']
            db.interestRateMax = lender['_InterestRateMax']
            db.termLengthMin = lender['_TermLengthMin']
            db.termLengthMax = lender['_TermLengthMax']
            db.termLengthType = lender['_TermLengthType']
            db.capitalizationStructure0 = lender['_CapitalizationStructure0']
            db.timeInBusiness = lender['_TimeInBusiness']
            db.lendingStates0 = lender['_LendingStates0']
            db.timeInBusiness = lender['_TimeInBusiness']
            db.otherLendingPreferences = lender['_OtherLendingPreferences']
            db.loanToValueMin = lender['_LoanToValueMin']
            db.loanToValueMax = lender['_LoanToValueMax']
            db.lendingCountries = lender['_LendingCountries']
            db.lendingCategory = lender['_LendingCategory']
            db.lendingTypes = lender['_LendingTypes']
            db.businessFinancingTypes = lender['_BusinessFinancingTypes']
            db.equityandCrowdFunding = lender['_EquityandCrowdFunding']
            db.mortageTypes = lender['_MortageTypes']
            db.save
        end
      end
    end
   
    @lenders=Lender.fields(:infusion_id).all
     end

  def index
    @lenders=Lender.all(:delete.ne => 1)

    @lenders.each do |lender|
        lndr = Lender.find_by_id("#{lender.id}")
        lndr.loanMaxDropDown = lender.loanMaxDropDown.to_i
        lndr.loanToValueMax = lender.loanToValueMax.to_i
        lndr.loanToValueMin = lender.loanToValueMin.to_i
        lndr.save
    end
    # @lenders.each do |lender|
    #   pas_string = (0...8).map { (65 + rand(26)).chr }.join
    #   User.delete_all(:email => lender.email)
    #   Broker.delete_all(:email => lender.email)
    #   uInfo = User.find_by_email("#{lender.email}")

    #    if !uInfo.blank?
    #       @roles = uInfo.roles
            
    #       @names = Array.new
    #       @roles.each do |role|
    #         @names = role['name']
    #       end

    #       check_broker = @names.include? 'Broker'
    #       if check_broker==false
    #          @roles.push(Role.new(:name=>'Broker'))
    #          @roles.push(Role.new(:name=>'Lender'))
    #          uInfo.roles=@roles
    #          uInfo.save
    #       else
    #        @roles.push(Role.new(:name=>'Lender'))
    #          uInfo.roles=@roles
    #          uInfo.save
    #       end

    #       db = Broker.find_by_email("#{lender.email}")
    #       if !db.blank?
    #         db.firstName = lender.firstName 
    #         db.lastName = lender.lastName
    #         db.name = lender.firstName+' '+lender.lastName
    #         db.company = lender.company
    #         db.jobTitle = lender.jobTitle
    #         db.streetAddress1 = lender.streetAddress1
    #         db.streetAddress2 = lender.streetAddress2
    #         db.city = lender.city
    #         db.state = lender.state
    #         db.postalCode = lender.postalCode
    #         db.country = lender.country
    #         db.phone1 = lender.phone1
    #         db.phone2 = lender.phone2
    #         db.fax1 = lender.fax1
    #         db.email = lender.email
    #         db.website = lender.website
    #         db.address2Street1 = lender.address2Street1
    #         db.address2Street2 = lender.address2Street2
    #         db.city2 = lender.city2
    #         db.state2 = lender.state2
    #         db.postalCode2 = lender.postalCode2
    #         db.country2 = lender.country2
    #         db.address3Street1 = lender.address3Street1
    #         db.address3Street2 = lender.address3Street2
    #         db.city3 = lender.city3
    #         db.state3 = lender.state3
    #         db.postalCode3 = lender.postalCode3
    #         db.country3 = lender.country3
    #         # db.password = pas_string
    #         db.lender = 1
    #         db.save

    #         #LoanUrlMailer.email_lender(db).deliver
    #         end
    #       else
        
    #         db = Broker.new
    #         db.firstName = lender.firstName 
    #         db.lastName = lender.lastName
    #         db.name = lender.firstName+' '+lender.lastName
    #         db.company = lender.company
    #         db.jobTitle = lender.jobTitle
    #         db.streetAddress1 = lender.streetAddress1
    #         db.streetAddress2 = lender.streetAddress2
    #         db.city = lender.city
    #         db.state = lender.state
    #         db.postalCode = lender.postalCode
    #         db.country = lender.country
    #         db.phone1 = lender.phone1
    #         db.phone2 = lender.phone2
    #         db.fax1 = lender.fax1
    #         db.email = lender.email
    #         db.website = lender.website
    #         db.address2Street1 = lender.address2Street1
    #         db.address2Street2 = lender.address2Street2
    #         db.city2 = lender.city2
    #         db.state2 = lender.state2
    #         db.postalCode2 = lender.postalCode2
    #         db.country2 = lender.country2
    #         db.address3Street1 = lender.address3Street1
    #         db.address3Street2 = lender.address3Street2
    #         db.city3 = lender.city3
    #         db.state3 = lender.state3
    #         db.postalCode3 = lender.postalCode3
    #         db.country3 = lender.country3
    #         db.password = pas_string
    #         db.lender = 1
    #         db.save

    #         LoanUrlMailer.email_lender(db).deliver
    #         @user = User.new
    #         authorize @user

    #         @roles = Array.new
    #         @roles.push(Role.new(:name=>'Broker'))
    #         @roles.push(Role.new(:name=>'Lender'))
    #         @user.roles = @roles
    #         @user.name = lender.firstName+' '+lender.lastName
    #         @user.email = lender.email
    #         @user.password = pas_string
    #         @user.save

    #       end
    
    # end

  end

  def refresh_lender
     @lenders=Lender.all(:delete.ne => 1)
    render partial: 'lenders/refresh_lender'
  end

  def search
    srch = "/"+params['search']+"/"
    srch_string = params['search'].downcase
    @lendrs = Lender.all(:delete.ne => 1)
    
    @ids=Array.new
    unless @lendrs.blank? 
      @lendrs.each do |lendr|
        unless lendr.company.blank?
          company = lendr.company.downcase
          if company.include? srch_string
            @ids<<lendr.id  
          end
        end

        unless lendr.email.blank?
          email = lendr.email.downcase
          if email.include? srch_string
            @ids<<lendr.id 
          end
        end
      end
    end
    
    @lenders=Lender.find(@ids)
    render partial: 'lenders/refresh_lender'
  end

  def delete_lenders
    ids=params[:moredata].split(",")
    ids.each do |number|
      lenderRecord=Lender.find(number)
      # lenderRecord.delete=1
      # lenderRecord.save

      uInfo = User.find_by_email("#{lenderRecord.email}")
      if !uInfo.blank?
            @is_admin = ""
        uInfo.roles.each do |role|
            if role.name == "Admin"
                @is_admin = "true"
            end
        end
        
        if @is_admin != "true"
            @brokr = Broker.find_by_email("#{lenderRecord.email}")
            if @brokr.blank?
                Lender.delete_all(:id => lenderRecord.id)
                User.delete_all(:email => "#{lenderRecord.email}")
            else
                if @brokr.plan == "lender"
                    Broker.delete_all(:email => "#{lenderRecord.email}")
                    User.delete_all(:email => "#{lenderRecord.email}")
                end
                if @brokr.lender == 1
                    Broker.delete_all(:email => "#{lenderRecord.email}")
                    User.delete_all(:email => "#{lenderRecord.email}")
                end
                Lender.delete_all(:id => lenderRecord.id)
            end
        else
            Lender.delete_all(:id => lenderRecord.id)
        end
      else
        Lender.delete_all(:id => lenderRecord.id)
      end
      
    end 
    refresh_lender   
   

    flash.now[:notice] = "Lenders deleted successfully"
  end
  
  def show
    @broker = Broker.find(params['id'])
    @loans = Loan.where(:email => @broker.email).all
    #abort("#{@loans.inspect}")
  end

  def fetch_detail
    @detail =  Lender.find(params['id'])
    render partial: 'lenders/lender_detail'
  end

  def custom_search
   
   #new_arr = aar1.present? & aar2.present? & aar3.present? & aar4.present?
   #abort("#{new_arr.inspect}")
    @search_i = 0
    custom_search = Array.new
    ############ Loan Min Max ################# 
    unless params['loanMinDropDown'].blank?
        min = params['loanMinDropDown'].to_i
        if params['loanMaxDropDown'].blank?
            max = "No Max"
            loan_lenders = Lender.where(:loanMinDropDown.lte => min, :loanMaxDropDown.gte => min).fields(:id, :loanMinDropDown).all
        else
            max = params['loanMaxDropDown']
            if max != "No Max"
              loan_lenders = Lender.where(:loanMinDropDown.lte => min, :loanMaxDropDown.gte => max).fields(:id, :loanMinDropDown).all
            else
             loan_lenders = Lender.where(:loanMinDropDown.lte => min, :loanMaxDropDown => 0).fields(:id, :loanMinDropDown).all
            end        
        end
        
    end

    unless params['loanMaxDropDown'].blank?
        if params['loanMaxDropDown'] != "No Max"
            max = params['loanMaxDropDown'].to_i
            if params['loanMinDropDown'].blank?
                loan_lenders = Lender.where(:loanMaxDropDown.gte => max, :loanMinDropDown.lte => max).fields(:id,:loanMinDropDown).all
            else
                min = params['loanMinDropDown'].to_i
               loan_lenders = Lender.where(:loanMinDropDown.lte => min, :loanMaxDropDown.gte => max).fields(:id, :loanMinDropDown).all
            end
        else
            max = params['loanMaxDropDown'].to_i
            if params['loanMinDropDown'].blank?
                loan_lenders = Lender.where(:loanMaxDropDown => 0).fields(:id, :loanMinDropDown).all
            else
                min = params['loanMinDropDown'].to_i
                loan_lenders = Lender.where(:loanMinDropDown.lte => min, :loanMaxDropDown => max).fields(:id, :loanMinDropDown).all
            end
        end
        
    end
# abort("#{loan_lenders.inspect}")

    unless loan_lenders.blank?
        # abort("1")
        lid = Array.new
       loan_lenders.each do |lender|
           lid<<lender['_id']
        end
            custom_search[@search_i] = lid 
            @search_i = @search_i+1
    end
    #abort("#{loan_lenders}")
    ############## Loan value #################



   

    unless params['loanToValueMin'].blank?
       if params['loanToValueMax'].blank?
           if params['loanToValueMin'] != "None"
            loan_val_lenders = Lender.where(:loanToValueMin.lte => params['loanToValueMin'].to_i, :loanToValueMax.gte => params['loanToValueMin'].to_i).fields(:id).all
           else
            loan_val_lenders = Lender.where(:loanToValueMin => 0).fields(:id).all
           end
        else
            if params['loanToValueMax'] != "None"
                loan_val_lenders = Lender.where(:loanToValueMin.lte => params['loanToValueMin'].to_i, :loanToValueMax.gte => params['loanToValueMax'].to_i).fields(:id).all
            else
                loan_val_lenders = Lender.where(:loanToValueMin.lte => params['loanToValueMin'].to_i, :loanToValueMax => 0).fields(:id).all
            end
       end
    end

    unless params['loanToValueMax'].blank?
       if params['loanToValueMin'].blank?
           if params['loanToValueMax'] != "None"
            loan_val_lenders = Lender.where(:loanToValueMin.lte => params['loanToValueMax'].to_i, :loanToValueMax.gte => params['loanToValueMax'].to_i).fields(:id).all
           else
            loan_val_lenders = Lender.where(:loanToValueMax.gte => 0).fields(:id).all
           end
       else
           if params['loanToValueMin'] != "None"
             loan_val_lenders = Lender.where(:loanToValueMin.lte => params['loanToValueMin'].to_i, :loanToValueMax.gte => params['loanToValueMax'].to_i).fields(:id).all
           else
            loan_val_lenders = Lender.where(:loanToValueMin => 0, :loanToValueMax.gte => params['loanToValueMax'].to_i).fields(:id).all
           end
       end
    end

    unless loan_val_lenders.blank?

        llid = Array.new
       loan_val_lenders.each do |llender|
           llid<<llender['_id']
        end
        custom_search[@search_i] = llid 
        @search_i = @search_i+1
    end

     ############## Points #################    
    #  unless params['pointsMin'].blank?
    #     if params['pointsMax'].blank?
    #          point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i).fields(:id).all
    #     else
    #          point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i, :pointsMax =>  params['pointsMax'].to_i).fields(:id).all
    #     end
    #  end

    #  unless params['pointsMax'].blank?
    #     if params['pointsMin'].blank?
    #          point_lenders = Lender.where(:pointsMax => params['pointsMax'].to_i).fields(:id).all
    #     else
    #         point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i, :pointsMax =>  params['pointsMax'].to_i).fields(:id).all
    #     end
    #  end

    # unless point_lenders.blank?

    #     pid = Array.new
    #    point_lenders.each do |plender|
    #        pid<<plender['_id']
    #     end
    #     custom_search[@search_i] = pid 
    #     @search_i = @search_i+1
    # end
    ############ Lending Category ##########
     unless params['lendingCategory'].blank?
        category_lenders = Lender.where(:lendingCategory => params['lendingCategory']).fields(:id).all 
        unless category_lenders.blank?
        cid = Array.new
        category_lenders.each do |clender|
           cid<<clender['_id']
        end
        custom_search[@search_i] = cid 
         @search_i = @search_i+1
        end
     end

     ############ Lending Types #############
     unless params['lendingTypes'].blank?
        types_lenders = Lender.where(:lendingTypes => /#{params['lendingTypes']}/).fields(:id).all
        unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[@search_i] = tid
         @search_i = @search_i+1 
        end
    end
     unless params['businessFinancingTypes'].blank?
        types_lenders = Lender.where(:businessFinancingTypes => /#{params['businessFinancingTypes']}/).fields(:id).all
         unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[@search_i] = tid
         @search_i = @search_i+1 
        end
     end
     unless params['equityandCrowdFunding'].blank?
        types_lenders = Lender.where(:equityandCrowdFunding => /#{params['equityandCrowdFunding']}/).fields(:id).all
        unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[@search_i] = tid 
        @search_i = @search_i+1
        end
     end
     unless params['mortageTypes'].blank?
        types_lenders = Lender.where(:mortageTypes => /#{params['mortageTypes']}/).fields(:id).all
        unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[@search_i] = tid
        @search_i = @search_i+1 
        end
     end

      ################## Interest Rate ##########
      unless params['interestRateMin'].blank?
        if params['interestRateMax'].blank?
             interest_lenders = Lender.where(:interestRateMin.lte => params['interestRateMin'].to_i, :interestRateMax.gte => params['interestRateMin'].to_i).fields(:id).all
        else 
             interest_lenders = Lender.where(:interestRateMin.lte => params['interestRateMin'].to_i, :interestRateMax.gte =>  params['interestRateMax'].to_i).fields(:id).all
        end
      end

      unless params['interestRateMax'].blank?
        if params['interestRateMin'].blank?
             interest_lenders = Lender.where(:interestRateMin.lte => params['interestRateMax'].to_i, :interestRateMax.gte => params['interestRateMax'].to_i).fields(:id).all
        else 
             interest_lenders = Lender.where(:interestRateMin.lte => params['interestRateMin'].to_i, :interestRateMax.gte =>  params['interestRateMax'].to_i).fields(:id).all
        end
      end

      unless interest_lenders.blank?
        iid = Array.new
        interest_lenders.each do |ilender|
           iid<<ilender['_id']
        end
        custom_search[@search_i] = iid 
        @search_i = @search_i+1
      end
      

      ############### States ###################
      
      unless params['lendingStates0'].blank?
         sid = Array.new
        params['lendingStates0'].each do |state|
            if state!=""
                # abort("#{state.inspect}")
             lender_state = Lender.where(:lendingStates0 =>/#{state}/).fields(:id).all
             lender_state.each do |slender|
                 sid<<slender['_id']
             end
            end
        end

        unless sid.blank?
           custom_search[@search_i] = sid
           @search_i = @search_i+1 
        end
      end



      ############# Term Length ####################

      unless params['termLengthMin'].blank?
        if params['termLengthMax'].blank?
           length_lenders = Lender.where(:termLengthMin.lte => params['termLengthMin'].to_i, :termLengthMax.gte => params['termLengthMin'].to_i).fields(:id).all
        else
           length_lenders = Lender.where(:termLengthMin.lte => params['termLengthMin'].to_i, :termLengthMax.gte => params['termLengthMax'].to_i).fields(:id).all
        end
      end

      unless params['termLengthMax'].blank?
        if params['termLengthMin'].blank?
           length_lenders = Lender.where(:termLengthMin.lte => params['termLengthMax'].to_i, :termLengthMax.gte => params['termLengthMax'].to_i).fields(:id).all
        else
           length_lenders = Lender.where(:termLengthMin.lte => params['termLengthMin'].to_i, :termLengthMax.gte => params['termLengthMax'].to_i).fields(:id).all
        end
      end
       # abort("#{length_lenders.inspect}")
        unless length_lenders.blank?
        lld = Array.new
        length_lenders.each do |lllender|
           lld<<lllender['_id']
        end
        custom_search[@search_i] = lld
        @search_i = @search_i+1 
        end

      
     
     select = Array.new
      custom_search.each do |search|
        unless search.blank?
            select<<search  
        end
      end

      num=select.count
       if num==1
        ids=select[0]
      elsif num==2
        ids=select[0]&select[1]
      elsif num==3
        
        ids=select[0]&select[1]&select[2]

      elsif num==4
        ids =select[0]&select[1]&select[2]&select[3]
      elsif num==5
        ids =select[0]&select[1]&select[2]&select[3]&select[4]
      elsif num==6
        ids =select[0]&select[1]&select[2]&select[3]&select[4]&select[5]
      elsif num==7
        ids =select[0]&select[1]&select[2]&select[3]&select[4]&select[5]&select[6]
      elsif num==8
        ids =select[0]&select[1]&select[2]&select[3]&select[4]&select[5]&select[6]&select[7]
      else

      end

      if !ids.blank?
        @lenders=Lender.find(ids)
      else
        @lenders=Lender.all(:delete.ne => 1)
      end

      render partial: 'lenders/refresh_lender'
     
 end

 def add
  
 end

 def download_csv_lender
    require "csv"
    @lenders=Lender.all(:delete.ne => 1, :order => :id.desc)
    filename="lenders_"+Time.now.strftime("%m%d%y%H%M%S")
    save_path = Rails.root.join('csvs',filename+'.csv')
    CSV.open(save_path, "wb") do |csv|
      csv << ["Name", "Company", "Email", "Phone", "Loan Amount", "Loan Interest", "Loan Value", "Term Length"]
      @lenders.each do |lender|
            @name = "#{lender.firstName} #{lender.lastName}"
            
            @loan_amount =  number_to_currency(lender.loanMinDropDown)
            if lender.loanMaxDropDown!=0
                 @max_amnt = number_to_currency(lender.loanMaxDropDown)
                if !lender.loanMinDropDown.blank?
                    @loan_amount = "#{@loan_amount} - #{@max_amnt}"
                end
            else
                if !lender.loanMinDropDown.blank?
                    @loan_amount = "#{@loan_amount} - No Max"
                end
            end

            @interest = ""
            if !lender.interestRateMin.blank? 
                if lender.interestRateMin!=""
                    @interest = "#{lender.interestRateMin}%"
                end
            end
            if !lender.interestRateMax.blank? 
                if !lender.interestRateMin.blank?
                    @interest = "#{lender.interestRateMin}% - #{lender.interestRateMax}%"
                else
                    @interest = "#{lender.interestRateMax}%"
                end 
            end

            @loan_value=""
            if lender.loanToValueMin == 0
                @loan_value="None"
            else
                @loan_value="#{lender.loanToValueMin}"
            end
           
            if !lender.loanToValueMax.blank?
                if !lender.loanToValueMin.blank?
                    @loan_value="#{@loan_value} - "
                end

                if lender.loanToValueMax == 0
                    
                else
                    @loan_value="#{@loan_value}#{lender.loanToValueMax}"
                end
            end

            @term_length = ""
            if lender.termLengthType=="year(s)"
                @term_length = "#{lender.termLengthMin}Years - #{lender.termLengthMax}Years"
            else
                @term_length = "#{lender.termLengthMin}Months - #{lender.termLengthMax}Months"
            end

            csv << ["#{@name}", "#{lender.company}", "#{lender.email}", "#{lender.phone1}", "#{@loan_amount}", "#{@interest}", "#{@loan_value}", "#{@term_length}"]
      end
    end

    send_file 'csvs/'+filename+'.csv', :type => 'text/csv'
  end

 def add_lender
      isBroker = params[:broker]
      params.delete :action
      params.delete :broker
      params.delete :controller
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
      db.firstName = params['FirstName']
      db.broker = isBroker  
      db.lastName = params['LastName']
      db.name = params['FirstName']+' '+params['LastName']
      db.company = params['Company']
      db.jobTitle = params['JobTitle']
      db.streetAddress1 = params['StreetAddress1']
      db.city = params['City']
      db.state = params['State']
      db.postalCode = params['PostalCode']
      db.email = params['Email']
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
    db.firstName = params['FirstName']
    db.lastName = params['LastName']
    db.name = params['FirstName']+' '+params['LastName']
    db.company = params['Company']
    db.jobTitle = params['JobTitle']
    db.streetAddress1 = params['StreetAddress1']
    db.city = params['City']
    db.state = params['State']
    db.plan = "lender"
    db.postalCode = params['PostalCode']
    db.email = params['Email']
    db.password = params['Password']
    db.lender = 1
    db.save

    LoanUrlMailer.email_lender(db).deliver

    @check = User.find_by_email(params['Email'])
        
    if @check.blank?
        user = User.new
        lname = "#{params[:firstName]} #{params[:lastName]}"
        user.name = lname.camelize 
        user.email = params[:Email].gsub(' ','')
        user.password = params[:Password]
        user.max_users = 1
        user.max_lenders = 5
        user.max_storage = "1Gb"
        user.max_upload = "10Mb"
        user.plan = "lender"
        user.market_access = 1
        usrname = params[:Username].downcase
        user.username = usrname.gsub(' ','')
        sub_domain =  usrname.gsub(/[^0-9A-Za-z]/, '')
        user.subdomain = sub_domain

        roles = Array.new
        roles.push(Role.new(:name=>'Broker'))
        roles.push(Role.new(:name=>'Lender'))
        user.roles = roles
        user.save
        # abort("#{user.inspect}")
    else
        @roles = @check.roles
            
        @names = Array.new
        @roles.each do |role|
            @names = role['name']
        end

        check_lender = @names.include? 'Lender'
        check_broker = @names.include? 'Broker'
        if check_lender==false
         @roles.push(Role.new(:name=>'Lender'))
        end
        if check_broker==false
         @roles.push(Role.new(:name=>'Broker'))
        end
         @check.roles=@roles
         @check.save
    end

    

    flash[:notice] = "Lender is added successfully"  
    redirect_to action: 'index'
 
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

 def potential_deals
    # abort("#{current_user.email}")
 	@all_lenders = Lender.find_by_email("#{current_user.email}")
    @broker= Broker.find_by_email("#{current_user.email}")
    # abort("#{brokers.inspect}")
    if @all_lenders.blank?
        lenderInfo = Lender.new
        lenderInfo.email = "#{@broker.email}"
        lenderInfo.save
        @all_lenders = Lender.find_by_id("#{lenderInfo.id}")
    end
    @ip = request.remote_ip
    if !@all_lenders.blank?
 		@loans = LoanLender.all(:lender_id => "#{@all_lenders.id}", :status.ne => nil)
 	end
    @agreement = LenderAgreement.last(:order => :id.asc)

    @agree = ""
    unless defined? @all_lenders.acept_agreement
        @agree = "false"
    else
        if  @all_lenders.acept_agreement!=1
            @agree = "false"
        end

        if @all_lenders.acept_agreement==1 && @all_lenders.agreement_id != @agreement.id.to_s
            @agree = "false"
        end
    end

    @adate = Time.now
    @bdate = Time.now.strftime("%d-%m-%y")
    
 end

  def loan_detail

   @info = LoanLender.find_by_id("#{params[:id]}")
    # abort("#{@info.inspect}")
    # num = 72*60*60
    # endtime=Time.now + num
    # @info.end_time = endtime
    # @info.save
    # abort("#{@info.inspect}")
  	lendr = @info.lender
    # abort("#{lendr.inspect}")
    etime = Time.parse(@info.end_time)
    @endt = etime.strftime("%a %b %d %Y %H:%M:%S")
  	now_time = Time.now
  	redirct = ""
  	if etime<now_time
      redirct = "true"
  	end
  	if !current_user.blank?
	  	
        loan_detail = CopyLoan.find_by_id(@info.copy_loan_id)
        if loan_detail.phase=="matching"
            loan_detail.phase = "review"
            loan_detail.save
        end
        # if current_user.email != lendr.email || @info.status == "decline"
	  	# 	 redirct = "true"
	   #  	@access = "false"
	   #  else
	    @access = "true"
	    # end
		@login = "true"
	else
		@access = "false"
		@login = "false"
        @setpas = "true"
	end

	 if @access == "true"
	 	@auth = "yes"
        @agreement = LenderAgreement.last(:order => :id.asc)

        @agree = ""
        if  lendr.acept_agreement!=1
            @agree = "false"
        end

        if lendr.acept_agreement==1 && lendr.agreement_id != @agreement.id.to_s
            @agree = "false"
        end

        @ip = request.remote_ip
        @adate = Time.now
        @bdate = Time.now.strftime("%d-%m-%y")
	 elsif @login == "false"
	 	@auth = "login"
	 else
	 	@auth = "auth"
	 end
	 		
     @loan = @info.copy_loan
     ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
     @ultv = ltv *100
     @lltv = @ultv.round(2)
     # abort("#{@lltv}")
     ############## Bar Chart ###################
          @funds = UseFund.all(:copy_loan_id => @info.copy_loan_id)
          @amnt = ""
          unless @funds.blank?
              @uses = Array.new
              @amounts = Array.new
              @uses<<""
              @amounts<<""
              @funds.each do |fund|
                if !fund.amount.blank?
                  if fund.use.blank?
                    @uses<< ""
                  else
                    @uses<< fund.use
                  end

                  if fund.amount.blank?
                    @amounts << 0
                  else
                    @amnt = "no zero"
                    unless fund.amount.blank?
                      @amounts<< fund.amount
                    else
                      @amounts<< 0
                    end
                  end
                end
              end
          end

          # abort("#{@funds.inspect} --- #{@amnt}")
     ############## End Bar Chart ###############

     @borrowers = CopyBorrower.all(:copy_loan_id => "#{@loan.id}")
     @collaterals = CopyCollateral.all(:copy_loan_id => "#{@loan.id}", :order => :sort_id.asc)
     
     if redirct=="true"
        flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
        redirect_to '/'
     end
     
     #################### Analysis ############################
    col_acres = CopyCollateralAcres.all(:copy_loan_id => @loan.id)
    @colacres = Hash.new
    col_acres.each do |col_acre|
      @colacres[col_acre.collateral_id.to_s] = col_acre.value
    end
    col_sqs = CopyCollateralSqfootage.all(:copy_loan_id => @loan.id) 
    @colsqs = Hash.new
    col_sqs.each do |col_sq|
      @colsqs[col_sq.collateral_id.to_s] = col_sq.value
    end
    # abort("#{@colsqs.inspect}")
    col_nois = CopyCollateralNoi.all(:copy_loan_id => @loan.id)
    @colnois = Hash.new
    col_nois.each do |col_noi|
      @colnois[col_noi.collateral_id.to_s] = col_noi.value
    end
    col_gross = CopyCollateralGross.all(:copy_loan_id => @loan.id)
    @colgross = Hash.new
    col_gross.each do |col_gros|
      @colgross[col_gros.collateral_id.to_s] = col_gros.value
    end
    #################### Analysis ############################
  end

  def loan
    # lenderfind = LoanLender.find_by_copy_loan_id_and_lender_id("58774214ab608a0d3f000072","559ba8a6ab608a0def000080")
    # abort("#{lenderfind.inspect}")

    @info = LoanLender.find_by_id("#{params[:id]}")
    # num = 72*60*60
    # endtime=Time.now + num
    # @info.end_time = endtime
    # @info.save
    # abort("#{@info.inspect}")
    lendr = @info.lender
    # abort("#{lendr.inspect}")
   
    redirct = ""
    # if etime<now_time
    #   redirct = "true"
    # end
    if !current_user.blank?
        
        loan_detail = CopyLoan.find_by_id(@info.copy_loan_id)
        if loan_detail.phase=="matching"
            loan_detail.phase = "review"
            loan_detail.save
        end
        # if current_user.email != lendr.email || @info.status == "decline"
        #    redirct = "true"
       #    @access = "false"
       #  else
        @access = "true"
        # end
        @login = "true"
    else
        @access = "false"
        @login = "false"
        @setpas = "true"
    end

     if @access == "true"
        @auth = "yes"
        @agreement = LenderAgreement.last(:order => :id.asc)

        @agree = ""
        if  lendr.acept_agreement!=1
            @agree = "false"
        end

        if lendr.acept_agreement==1 && lendr.agreement_id != @agreement.id.to_s
            @agree = "false"
        end

        @ip = request.remote_ip
        @adate = Time.now
        @bdate = Time.now.strftime("%d-%m-%y")
     elsif @login == "false"
        @auth = "login"
     else
        @auth = "auth"
     end
            
     @loan = @info.copy_loan
     ltv = @loan.info['_NetLoanAmountRequested0'].to_f/@loan.info['_EstimatedMarketValue'].to_f
     @ultv = ltv *100
     @lltv = @ultv.round(2)
     # abort("#{@lltv}")
     ############## Bar Chart ###################
          @funds = UseFund.all(:copy_loan_id => @info.copy_loan_id)
          @amnt = ""
          unless @funds.blank?
              @uses = Array.new
              @amounts = Array.new
              @uses<<""
              @amounts<<""
              @funds.each do |fund|
                if !fund.amount.blank?
                  if fund.use.blank?
                    @uses<< ""
                  else
                    @uses<< fund.use
                  end

                  if fund.amount.blank?
                    @amounts << 0
                  else
                    @amnt = "no zero"
                    unless fund.amount.blank?
                      @amounts<< fund.amount
                    else
                      @amounts<< 0
                    end
                  end
                end
              end
          end

          # abort("#{@funds.inspect} --- #{@amnt}")
     ############## End Bar Chart ###############

     @borrowers = CopyBorrower.all(:copy_loan_id => "#{@loan.id}")
     @collaterals = CopyCollateral.all(:copy_loan_id => "#{@loan.id}", :order => :sort_id.asc)
     
     if redirct=="true"
        flash[:alert] ='You have either selected an invalid loan or you are not authorized to view this loan.'
        redirect_to '/'
     end
     
     #################### Analysis ############################
    col_acres = CopyCollateralAcres.all(:copy_loan_id => @loan.id)
    @colacres = Hash.new
    col_acres.each do |col_acre|
      @colacres[col_acre.collateral_id.to_s] = col_acre.value
    end
    col_sqs = CopyCollateralSqfootage.all(:copy_loan_id => @loan.id) 
    @colsqs = Hash.new
    col_sqs.each do |col_sq|
      @colsqs[col_sq.collateral_id.to_s] = col_sq.value
    end
    # abort("#{@colsqs.inspect}")
    col_nois = CopyCollateralNoi.all(:copy_loan_id => @loan.id)
    @colnois = Hash.new
    col_nois.each do |col_noi|
      @colnois[col_noi.collateral_id.to_s] = col_noi.value
    end
    col_gross = CopyCollateralGross.all(:copy_loan_id => @loan.id)
    @colgross = Hash.new
    col_gross.each do |col_gros|
      @colgross[col_gros.collateral_id.to_s] = col_gros.value
    end
    #################### Analysis ############################

     @agree = "true"
  end


 def acept_loan
    info = LoanLender.find_by_id("#{params[:id]}")
    info.status = "accept"
    info.save

    loan_detail = CopyLoan.find_by_id(info.copy_loan_id)
    loan_detail.phase = "identified"
    loan_detail.save

    LoanUrlMailer.loan_accepted("#{info.id}").deliver
    LoanUrlMailer.loan_to_lender("#{info.id}").deliver
    render text: "done"
  end

  def acept_shop_loan
    info = LoanLender.find_by_id("#{params[:id]}")
    info.status = "accept"
    info.save

    # loan_detail = CopyLoan.find_by_id(info.copy_loan_id)
    # loan_detail.phase = "identified"
    # loan_detail.save

    LoanUrlMailer.shop_loan_accepted("#{info.id}").deliver
    LoanUrlMailer.shop_loan_to_lender("#{info.id}").deliver
    render text: "done"
  end

  def decline_loan
  	lender = LoanLender.find_by_id("#{params[:id]}")
  	lender.status = "decline"
  	lender.save

    loan_detail = CopyLoan.find_by_id(info.copy_loan_id)
    loan_detail.phase = "decline"
    loan_detail.save

    start_time=Time.now
    if defined? lender.hours 
        if lender.hours != nil
            num = lender.hours*60*60
        else
            num = 24*60*60
        end
    else
        num = 24*60*60
    end
    end_time=Time.now + num
    etime = Time.parse lender.end_time

           

    ############# Fetch Next Lender ##############
    priority = lender.priority + 1
    loan = lender.copy_loan_id
    # abort("#{loan.inspect}")
    check_accept = LoanLender.all(:status => "accept", :copy_loan_id => "#{loan}")
    if check_accept.blank?
        next_lender = LoanLender.all(:priority =>priority, :copy_loan_id => "#{loan}")
        if !next_lender.blank?
            next_lender.each do |nlender|
               
                nlender.send_date = start_time
                nlender.start_time = start_time
                nlender.end_time = end_time
                nlender.status = "active"
                nlender.save
                allreminders = Reminder.all(:copy_loan_id => "#{loan}" )
                allreminders.each do |remind|
                    rm = Reminder.find_by_id(remind.id)
                    # abort("#{rm.inspect}")
                    rm.status = 0
                    rm.save
                end
               LoanUrlMailer.lender_shop_loan(nlender.id).deliver
            end
        end
    end
    ############# End Fetch Next Lender ##############
  	render text: "done"
  end

  def decline_shop_loan
    lender = LoanLender.find_by_id("#{params[:id]}")
    # abort("#{lender.inspect}")
    lender.status = "decline"
    lender.save

    loan_detail = CopyLoan.find_by_id(lender.copy_loan_id.to_s)
    loan_detail.phase = "decline"
    loan_detail.save

    
    render text: "done"
  end


  def prefrences
  	 @lender = Lender.find_by_email("#{current_user.email}")
     #@lender = Lender.all(:email => "#{current_user.email}")
     # Lender.delete_all(:email => "#{current_user.email}", :id.ne=>"5601134adba1d62ec7000002")
     # @lender = Lender.all(:email => "#{current_user.email}")
     if @lender.blank?
  		@lender =  Broker.find_by_email("#{current_user.email}")
  	 end


  end

  def loan_custom_search

    
    ###################################### Fetch Loans #####################################################################
    
    @all_lenders = Lender.find_by_email("#{current_user.email}")
    all_loans = LoanLender.where(:lender_id => "#{@all_lenders.id}", :status.ne => nil).all
 	# cloans = Array.new
 	# @loans.each do |cloan_id|
 	# 	cloans << cloan_id.copy_loan_id
 	# end

 	# all_loans = CopyLoan.all(:id => cloans)
 	
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
       if defined? loan.copy_loan.info['_NetLoanAmountRequested0']
          
          if loan.copy_loan.info['_NetLoanAmountRequested0'].to_i>=params['loanMinDropDown'].to_i &&  loan.copy_loan.info['_NetLoanAmountRequested0'].to_i<=params['loanMaxDropDown'].to_i
              by_loanmin << loan.id
          end
        end
      end

      if params['loanMaxDropDown'].to_i==0
          if defined? loan.copy_loan.info['_NetLoanAmountRequested0']
            if loan.copy_loan.info['_NetLoanAmountRequested0'].to_i>=params['loanMinDropDown'].to_i
             by_loanmin << loan.id
            end 
          end
      end

      ####################################################### Loan Value End ################################################
    
      ###################################################### States ##########################################################
      unless params['State3'].blank?
        if defined? loan.copy_loan.info['State3']
          params['State3'].each do |state|
              if loan.copy_loan.info['State3']==state
                  state_id<<loan.id
              end
          end   
        end
      end
      ###################################################### States End ######################################################
      
      ###################################################### Lending Category ################################################
      
       unless params['lendingCategory'].blank?
        if defined? loan.copy_loan.info['_LendingCategory']
          if loan.copy_loan.info['_LendingCategory'] == params['lendingCategory']
              loan_cat << loan.id
          end
        end
       end

      ###################################################### Lending Category End ################################################
      
      ###################################################### Lending Type ########################################################
        
       unless params['lendingTypes'].blank?
        type = "yes"
        if defined? loan.copy_loan.info['_LendingTypes']
          unless loan.copy_loan.info['_LendingTypes'].blank?
            #lending_types = loan.info['_LendingTypes'].split(",")
            if loan.copy_loan.info['_LendingTypes'] == params['lendingTypes']
                loan_type << loan.id
            end
          end
        end
     end


     unless params['businessFinancingTypes'].blank?
        type = "yes"
         if defined? loan.copy_loan.info['_BusinessFinancingTypes']
          unless loan.copy_loan.info['_BusinessFinancingTypes'].blank?
            #business_types = loan.info['_BusinessFinancingTypes'].split(",")
              if loan.copy_loan.info['_BusinessFinancingTypes'] == params['businessFinancingTypes']
                loan_type << loan.id
            end
          end
        end
     end
     unless params['equityandCrowdFunding'].blank?
        type = "yes"
        if defined? loan.copy_loan.info['_EquityandCrowdFunding']
          unless loan.copy_loan.info['_EquityandCrowdFunding'].blank?
          #lending_types = loan.info['_EquityandCrowdFunding'].split(",")
            if loan.copy_loan.info['_EquityandCrowdFunding'] == params['equityandCrowdFunding']
                loan_type << loan.id
            end
          end
        end
     end
     unless params['mortageTypes'].blank?
        type = "yes"
        if defined? loan.copy_loan.info['_MortageTypes']
          unless loan.copy_loan.info['_MortageTypes'].blank?
            #lending_types = loan.info['_MortageTypes'].split(",")
            if loan.copy_loan.info['_MortageTypes'] == params['mortageTypes']
                loan_type << loan.id
            end
          end
        end
     end

      ###################################################### Lending Type End ####################################################
    end 
      custom_search[0] = by_loanmin 

      # if !by_loanmin.blank?
      # 	abort("#{by_loanmin.inspect}")
      # end
      
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
   	  @loans_record = LoanLender.find(ids)
      

      if @loans_record.blank?
        @loans = Array.new
        @empty =  "No Potential deals found."
      else
        @loans=@loans_record.reverse { |k| k['id'] }
      end
      #flash.now[:notice] = "Searching by recent Loans"
      render partial: 'lenders/all_loans'
   ########################################### Check Sorting End ##############################################
  end

  def add_edit_lender
      isBroker = params[:broker]
      params.delete :action
      params.delete :broker
      params.delete :controller
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
      if params['id'].blank?
      	db = Lender.new()
  	  else
  	  	db = Lender.find_by_id(params['id'])
  	  end
      #db.infusion_id = infusion_id
      db.firstName = params['FirstName']
      db.broker = isBroker  
      db.lastName = params['LastName']
      db.name = params['FirstName']+' '+params['LastName']
      db.company = params['Company']
      db.jobTitle = params['JobTitle']
      db.streetAddress1 = params['StreetAddress1']
      db.city = params['City']
      db.state = params['State']
      db.postalCode = params['PostalCode']
      db.email = params['Email']
      db.loanMinDropDown = params['_LoanMinDropDown'].to_i
      db.loanMaxDropDown = params['_LoanMaxDropDown']
      db.pointsMin = params['_PointsMin'].to_i
      db.pointsMax = params['_PointsMax'].to_i
      db.interestRateMax = params['_InterestRateMax'].to_i
      db.interestRateMin = params['_InterestRateMin'].to_i
      db.termLengthMin = params['_TermLengthMin'].to_i
      db.termLengthMax = params['_TermLengthMax'].to_i
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
      # abort("#{db.inspect}")
      db.save

     chck = Broker.find_by_email(params['Email'])
    if chck.blank?
     db = Broker.new
 	else
     db = Broker.find_by_email(params['Email'])
 	end
    db.firstName = params['FirstName']
    db.lastName = params['LastName']
    db.name = params['FirstName']+' '+params['LastName']
    db.company = params['Company']
    db.jobTitle = params['JobTitle']
    db.streetAddress1 = params['StreetAddress1']
    db.city = params['City']
    db.state = params['State']
    db.postalCode = params['PostalCode']
    db.email = params['Email']
    db.password = params['Password']
    db.lender = 1
    db.save

     @check = User.find_by_email(params['Email'])
    if !@check.blank?
    	@roles = @check.roles
            
        @names = Array.new
        @roles.each do |role|
          @names = role['name']
        end
        
        check_lender = @names.include? 'Lender'
        if check_lender==false
           @roles.push(Role.new(:name=>'Lender'))
           @check.roles=@roles
           @check.save
        end
    end

    flash[:notice] = "Lender is updated successfully"  
	redirect_to action: 'potential_deals'
 
 end

 def lender_agreements
    @agreements = LenderAgreement.all(:order => :id.desc)
 end

 def add_agreement
   
 end

 def agreement_add
    agrmnt = LenderAgreement.new
    agrmnt.header = params[:header]
    agrmnt.content = params[:content]
    agrmnt.added_by = params[:added_by]
    agrmnt.added_date = Time.now
    agrmnt.save

    redirect_to action: 'lender_agreements'
 end

 def accept_agreement
    
    lender = Lender.find_by_id("#{params[:lender_id]}")
    lender.acept_agreement = 1
    lender.agreement_id = params[:agreement_id]
    lender.signature = params[:signature]
    lender.agreement_date = params[:agreement_date]
    lender.agreement_date_time = params[:agreement_date_time]
    lender.ip_address = params[:ip_address]
    lender.save

    render text:"done"
 
 end

##################### Cron For active status ########################
 def lender_cron
    lenders = LoanLender.all(:status => "active", :saved=>1)


    current_time = Time.now
    if !lenders.blank?
        lenders.each do |lend|
            start_time=Time.now
            if defined? lend.hours 
                if lend.hours != nil
                    num = lend.hours*60*60
                else
                    lhours = 24
                    num = 24*60*60
                end
            else
                lhours = 24
                num = 24*60*60
            end
            end_time=Time.now + num
            etime = Time.parse lend.end_time

            if etime<current_time
                
                ############### Set Decline Status ###########
                    ldr = LoanLender.find_by_id("#{lend.id}")
                    ldr.status = "decline"
                    ldr.save
                ############### End Set Decline Status #######

                ############# Fetch Next Lender ##############
                priority = lend.priority + 1
                loan = lend.copy_loan_id
                # abort("#{loan.inspect}")
                check_accept = LoanLender.all(:status => "accept", :copy_loan_id => "#{loan}",  :saved=>1)
                if check_accept.blank?
                    next_lender = LoanLender.all(:priority =>priority, :copy_loan_id => "#{loan}",  :saved=>1, :status.ne => 'active')
                    if !next_lender.blank?
                        next_lender.each do |nlender|
                            if nlender.status != "decline"
                                nlender.send_date = start_time
                                nlender.start_time = start_time
                                nlender.end_time = end_time
                                nlender.status = "active"
                                nlender.save
                                allreminders = Reminder.all(:copy_loan_id => "#{loan}" )
                                allreminders.each do |remind|
                                    rm = Reminder.find_by_id(remind.id)
                                    rm.status = 0
                                    rm.save
                                end
                                LoanUrlMailer.lender_shop_loan(nlender.id).deliver
                                # LoanUrlMailer.test_email("Lender Cron Email").deliver
                            end

                             # LoanUrlMailer.test_email("Lender Cron").deliver
                        end
                    end
                end
                ############# End Fetch Next Lender ##############
               
            end
        end
    end
    # LoanUrlMailer.test_email("Lender Cron Function").deliver
    render text: "done"
 end

##################### Cron For decline status ########################
 def decline_cron
    lenders = LoanLender.all(:status => "decline", :saved=>1)

    current_time = Time.now
    if !lenders.blank?
        lenders.each do |lend|
            start_time=Time.now
            if defined? lend.hours 
                if lend.hours != nil
                    num = lend.hours*60*60
                else
                    num = 24*60*60
                end
            else
                num = 24*60*60
            end
            end_time=Time.now + num
            etime = Time.parse lend.end_time

           

                ############# Fetch Next Lender ##############
                priority = lend.priority + 1
                loan = lend.copy_loan_id
                # abort("#{loan.inspect}")
                check_accept = LoanLender.all(:status => "accept", :copy_loan_id => "#{loan}", :saved=>1)
                if check_accept.blank?
                    next_lender = LoanLender.all(:priority =>priority, :copy_loan_id => "#{loan}",  :saved=>1, :status.ne => "active")
                    if !next_lender.blank?
                        next_lender.each do |nlender|
                           if nlender.status != "decline"
                                nlender.send_date = start_time
                                nlender.start_time = start_time
                                nlender.end_time = end_time
                                nlender.status = "active"
                                nlender.save
                                allreminders = Reminder.all(:copy_loan_id => "#{loan}" )
                                allreminders.each do |remind|
                                    rm = Reminder.find_by_id(remind.id)
                                    rm.status = 0
                                    rm.save
                                end
                                LoanUrlMailer.lender_shop_loan(nlender.id).deliver
                                # LoanUrlMailer.test_email("DeclineEmail").deliver
                           end 
                             # LoanUrlMailer.test_email("Decline").deliver
                        end
                    end
                end
                ############# End Fetch Next Lender ##############
               
            end
        end
  
    # LoanUrlMailer.test_email("dECLINE Cron Function").deliver
    render text: "done"
 end

def reminders
    # LoanUrlMailer.test_email("Reminder").deliver
    lenders = LoanLender.all(:status => "active", :saved => 1)
    lenders.each do |lend|
        etime=Time.parse(lend.end_time)
        current_time = Time.now
        if etime>current_time
            reminders = Reminder.all(:copy_loan_id => lend.copy_loan_id.to_s, :status =>0 )
            
            reminders.each do |remnder|
               
                if remnder.units == "hours"
                    left = TimeDifference.between(etime, current_time).in_hours
                    
                    lft_hour = left.round
                    if lft_hour == remnder.num
                        rm = Reminder.find_by_id(remnder.id)
                        rm.status = 1
                        rm.save
                        LoanUrlMailer.shop_loan_reminder(remnder.id, lend.id).deliver
                        # LoanUrlMailer.test_email("Reminder Email Sent").deliver
                    end
                end

                if remnder.units == "min"
                    left = TimeDifference.between(etime, current_time).in_minutes
                    lft_min = left.round
                    if lft_min == remnder.num
                        rm = Reminder.find_by_id(remnder.id)
                        rm.status = 1
                        rm.save
                        LoanUrlMailer.shop_loan_reminder(remnder.id, lend.id).deliver
                        LoanUrlMailer.test_email("Reminder Email Sent").deliver
                    end
                end
            end
        end
    end

    render text:"done"
end

def cancel_shop_loan
    @lenders = LoanLender.all(:copy_loan_id => "#{params[:loanId]}")
    @lenders.each do |lendr|
        lndr = LoanLender.find_by_id(lendr.id)
        lndr.status = ""
        lndr.save
    end
    render text:"done"
end

def test_time
    ctime=Time.now
    info = LoanLender.all(:copy_loan_id =>'56166316dba1d6329c000001')
    lenders = LoanLender.all(:status => "active", :saved=>1)
    
    lenders = LoanLender.all(:status => "active")
current_time = Time.now
   if !lenders.blank?
        lenders.each do |lend|
            start_time=Time.now
            if defined? lend.hours 
                if lend.hours != nil
                    num = lend.hours*60*60
                else
                    lhours = 24
                    num = 24*60*60
                end
            else
                lhours = 24
                num = 24*60*60
            end
            end_time=Time.now + num
            etime = Time.parse lend.end_time

            if etime<current_time
                
                ############### Set Decline Status ###########
                    ldr = LoanLender.find_by_id("#{lend.id}")
                    abort("#{ldr.inspect}")
                    ldr.status = "decline"
                    ldr.save
                ############### End Set Decline Status #######

                ############# Fetch Next Lender ##############
                priority = lender.priority + 1
                loan = lender.copy_loan_id
                # abort("#{loan.inspect}")
                check_accept = LoanLender.all(:status => "accept", :copy_loan_id => "#{loan}")
                if check_accept.blank?
                    next_lender = LoanLender.all(:priority =>priority, :copy_loan_id => "#{loan}")
                    if !next_lender.blank?
                        next_lender.each do |nlender|
                           
                            nlender.send_date = start_time
                            nlender.start_time = start_time
                            nlender.end_time = end_time
                            nlender.status = "active"
                            nlender.save
                            allreminders = Reminder.all(:copy_loan_id => "#{loan}" )
                            allreminders.each do |remind|
                                rm = Reminder.find_by_id(remind.id)
                                rm.status = 0
                                # rm.save
                            end
                            LoanUrlMailer.lender_shop_loan(nlender.id).deliver
                            

                            # LoanUrlMailer.test_email("Lender Cron").deliver
                        end
                    end
                end
                ############# End Fetch Next Lender ##############
               
            end
        end
    end
    
end

def groups
    @total = ShopGroup.count(:delete.ne => 1)
    # unless params[:per_page].blank?
    #   @groups = ShopGroup.paginate(:per_page => params[:per_page], :page => params[:page], :total_entries => @total)
    # else
    #   @groups = ShopGroup.paginate(:per_page => 10, :page => params[:page], :total_entries => @total)
    # end
    @groups = ShopGroup.all
    @lenders=Lender.all(:delete.ne => 1)
end

def add_group

    # abort("#{current_user.inspect}")
    group = ShopGroup.new
    group.name = params['group']
    group.created_by = params['user_id']
    group.created_date = Time.now 
    group.save

    params['lenders'].each do |lender|
        lendrInfo = Lender.find_by_email("#{lender}")
        unless lendrInfo.blank?
            info = LenderGroup.new
            info.group_id = group.id
            info.lender_id = lendrInfo.id
            info.save
        end
    end

    redirect_to action: 'groups' 
end

def view_group
    @group=ShopGroup.find_by_id("#{params['id']}")
    @group_lenders = LenderGroup.all(:group_id=>"#{params['id']}")
    # abort("#{@group_lenders.inspect}")
end

def shop_loan
    @lenderInfo = Lender.find_by_email("#{current_user.email}")
    unless params[:per_page].blank?
      @loans = LoanLender.paginate(:lender_id => @lenderInfo.id, :status =>"accept", :per_page => params[:per_page], :page => params[:page], :total_entries => @total, :order => :id.desc)
    else
      @loans = LoanLender.paginate(:lender_id => @lenderInfo.id, :status =>"accept", :per_page => 10, :page => params[:page], :total_entries => @total, :order => :id.desc)
    end
end
  
end
