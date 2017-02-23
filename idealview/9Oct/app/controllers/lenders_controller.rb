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
  end

  def refresh_lender
     @lenders=Lender.all(:delete.ne => 1)
    render partial: 'lenders/refresh_lender'
  end

  def search
    srch = "/"+params['search']+"/"
    @lenders = Lender.all(company: /#{params['search']}/)
    @ids=Array.new
    @lenders.each do |lender|
      @ids<<lender.id
    end
    @lendrs = Lender.all(email: /#{params['search']}/)
    @lendrs.each do |lendr|
      @ids<<lendr.id
    end
    
    @lenders=Lender.find(@ids)
    render partial: 'lenders/refresh_lender'
  end

  def delete_lenders
    ids=params[:moredata].split(",")
    ids.each do |number|
      lenderRecord=Lender.find(number)
      lenderRecord.delete=1
      lenderRecord.save
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
    custom_search = Array.new
    ############ Loan Min Max ################# 
    unless params['loanMinDropDown'].blank?
        min = params['loanMinDropDown'].to_i
        if params['loanMaxDropDown'].blank?
            max = "No Max"
        else
            max = params['loanMaxDropDown']
        end
        loan_lenders = Lender.where(:loanMinDropDown => min, :loanMaxDropDown => max).fields(:id).all
    end

    unless params['loanMaxDropDown'].blank?
        max = params['loanMaxDropDown']
        if params['loanMinDropDown'].blank?
            min=0
        else
            min = params['loanMinDropDown'].to_i
        end
        loan_lenders = Lender.where(:loanMinDropDown => min, :loanMaxDropDown => max).fields(:id).all
    end
#abort("#{loan_lenders.inspect}")

    unless loan_lenders.blank?

        lid = Array.new
       loan_lenders.each do |lender|
           lid<<lender['_id']
        end
            custom_search[0] = lid 
    end
    #abort("#{loan_lenders}")
    ############## Loan value #################
    unless params['loanToValueMin'].blank?
       if params['loanToValueMax'].blank?
           loan_max = "None"
       else
            loan_max = params['loanToValueMax']
       end
       loan_val_lenders = Lender.where(:loanToValueMin => params['loanToValueMin'], :loanToValueMax => loan_max).fields(:id).all
    end

    unless params['loanToValueMax'].blank?
       if params['loanToValueMin'].blank?
           loan_min = "None"
       else
            loan_min = params['loanToValueMin']
       end
       loan_val_lenders = Lender.where(:loanToValueMin => loan_min, :loanToValueMax => params['loanToValueMax']).fields(:id).all
    end

    unless loan_val_lenders.blank?

        llid = Array.new
       loan_val_lenders.each do |llender|
           llid<<llender['_id']
        end
        custom_search[1] = llid 
    end

     ############## Points #################    
     unless params['pointsMin'].blank?
        if params['pointsMax'].blank?
             point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i).fields(:id).all
        else
             point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i, :pointsMax =>  params['pointsMax'].to_i).fields(:id).all
        end
     end

     unless params['pointsMax'].blank?
        if params['pointsMin'].blank?
             point_lenders = Lender.where(:pointsMax => params['pointsMax'].to_i).fields(:id).all
        else
            point_lenders = Lender.where(:pointsMin => params['pointsMin'].to_i, :pointsMax =>  params['pointsMax'].to_i).fields(:id).all
        end
     end

 unless point_lenders.blank?

        pid = Array.new
       point_lenders.each do |plender|
           pid<<plender['_id']
        end
        custom_search[2] = pid 
    end
    ############ Lending Category ##########
     unless params['lendingCategory'].blank?
        category_lenders = Lender.where(:lendingCategory => params['lendingCategory']).fields(:id).all 
        unless category_lenders.blank?
        cid = Array.new
        category_lenders.each do |clender|
           cid<<clender['_id']
        end
        custom_search[3] = cid 
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
        custom_search[4] = tid 
        end
    end
     unless params['businessFinancingTypes'].blank?
        types_lenders = Lender.where(:businessFinancingTypes => /#{params['businessFinancingTypes']}/).fields(:id).all
         unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[4] = tid 
        end
     end
     unless params['equityandCrowdFunding'].blank?
        types_lenders = Lender.where(:equityandCrowdFunding => /#{params['equityandCrowdFunding']}/).fields(:id).all
        unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[4] = tid 
        end
     end
     unless params['mortageTypes'].blank?
        types_lenders = Lender.where(:mortageTypes => /#{params['mortageTypes']}/).fields(:id).all
        unless types_lenders.blank?
        tid = Array.new
        types_lenders.each do |tlender|
           tid<<tlender['_id']
        end
        custom_search[4] = tid 
        end
     end

      ################## Interest Rate ##########
      unless params['interestRateMin'].blank?
        if params['interestRateMax']!="0" and params['interestRateMin']!="0"
             interest_lenders = Lender.where(:interestRateMin => params['interestRateMin'].to_i, :interestRateMax => params['interestRateMax'].to_i).fields(:id).all
        elsif params['interestRateMin']=="0"
            interest_lenders = Lender.where(:interestRateMax => params['interestRateMax'].to_i).fields(:id).all
        else 
             interest_lenders = Lender.where(:interestRateMin => params['interestRateMin'].to_i, :pointsMax =>  params['pointsMax']).fields(:id).all
        end
       unless interest_lenders.blank?
        iid = Array.new
        interest_lenders.each do |ilender|
           iid<<ilender['_id']
        end
        custom_search[5] = iid 
        end
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
           custom_search[6] = sid 
        end
      end



      ############# Term Length ####################

      unless params['termLengthMin']==0
       length_lenders = Lender.where(:termLengthMin => params['termLengthMin'].to_i, :termLengthMax => params['termLengthMax'].to_i, :termLengthType => params['termLengthType']).fields(:id).all
       # abort("#{length_lenders.inspect}")
        unless length_lenders.blank?
        lld = Array.new
        length_lenders.each do |lllender|
           lld<<lllender['_id']
        end
        custom_search[7] = lld 
        end

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
      else
        ids =select[0]&select[1]&select[2]&select[3]&select[4]&select[5]&select[6]&select[7]
      end

      @lenders=Lender.find(ids)
       render partial: 'lenders/refresh_lender'
     
 end

 def add
  
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
      flash[:notice] = "Lender is added successfully"  
      redirect_to action: 'index'
 end

 def check_email
  lenders = Lender.find_by_email(params[:email])
  if lenders.blank?
    @rsp = "yes"
  else
    @rsp = "no"
  end
  render plain: @rsp
 end
  
end
