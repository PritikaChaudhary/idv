    #############################################################################################
    #
    #     This controller defines actions that links in emails from infusionsoft use to control
    #     the loan process. If you don't know what this means or don't understand where every detail is
    #     don't touch this file. You will break the process.
    #
    #############################################################################################



class Api::ActionsController < ApplicationController

  def match_lender
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != 'ab2cb0605482e82e89765f641cdfa07b'
      render nothing: true
      return
    end
    fields = Loan::regular_fields | Loan::custom_fields
    loan_id = params[:id]
    loan = Infusionsoft.data_load('Contact', loan_id, fields)
    category = loan['_LendingCategory']

    #############################################################################################
    #
    #     gather info and rank the lenders by how well they match the loan criteria
    #
    #############################################################################################

    if !loan.blank?
      #only grab the lenders that lend in the loan category
      lenders = Infusionsoft.data_query('Contact',1000,0,{:ContactType=>'Lender', :_LendingCategory=>category},Loan::lender_fields)
      if !lenders.blank?
        #set values for comparison
        loanType = loan_type(loan)
        net_amount = loan['_NetLoanAmountRequested0'].to_i
        term_length = loan['_DesiredTermLength'].to_i
        market_value = loan['_EstimatedMarketValue'].to_i
        ltv = market_value>0?(net_amount/market_value)*100:0
        us_state = loan['_CollateralState'] ||= 'none'
        num_lenders_shopped = loan['_NumberOfLendersShopped'].to_i
        
        #rank the lenders
        matches = Array.new
        lenders.each do |lender|
          if !lender['Groups'].include? '355'
            rank = 0.0
            rank += match_state(lender, us_state)
            #exclude if they don't lend in that state
            (rank == 0.0) ? next : nil
                    
            rank += match_loan_type(lender, loanType)
            rank += match_net_amount(lender, net_amount)
            rank += match_term_length(lender, term_length)
            rank += match_ltv(lender, ltv)
            rank += match_time_in_business(lender)
            rank += match_internal_rank(lender)
            rank += match_closes_rank(lender)
           
           (rank>0) ? matches<<{'id'=>lender['id'], 'email'=>lender['Email'], 'rank'=>rank.to_f} :nil
         
          end
        end
        
      end
    end
    
    matches.sort_by!{|x| x['rank']}.reverse!


    #############################################################################################
    #
    #     transact updates in infusionsoft based on the matches.
    #
    #############################################################################################

    
    #use the first match if this is the first request for a lender match
    if loan['_LenderEmail'].blank? && loan['_NumberOfLendersShopped'].to_i<1
      lender = matches.first
      #lender['email']
      update_data = {:_LenderEmail=>lender['email'], :_NumberOfLendersShopped=>1}
      Infusionsoft.contact_update(loan_id, update_data)
    else
    #use the next lender in the list if this is a subsequent request
      num_lenders = matches.length
      #empty the lenders email once all the lenders have been shopped.  
      if (num_lenders <= loan['_NumberOfLendersShopped'].to_i)
        Infusionsoft.contact_update(loan_id, {:_LenderEmail=>''})
        render plain: 'Out of Lenders'
        return
      end
      
      if !matches[loan['_NumberOfLendersShopped'].to_i].blank?
        lender = matches[loan['_NumberOfLendersShopped'].to_i]
        #just in case another lender was added somewhere along the way
        if lender['email'] == loan['_LenderEmail']
          next_num = loan['_NumberOfLendersShopped'].to_i+1 
          if !matches[next_num].blank?
            lender = matches[next_num]
          else
            render plain: 'No More Matches'
            return
          end
        end
        x = loan['_NumberOfLendersShopped'].to_i+1
        Infusionsoft.contact_update(loan_id, {:_LenderEmail=>lender['email'], :_NumberOfLendersShopped=>x})
        render plain: lender
        return
      end
    end  
    render plain: matches;
 end
  
 
 
 
 
 def shop_loan
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != '54b0c58c7ce9f2a8b551351102ee0938'
      @error = true
      return
    end
    
   loan_id = params[:id]
   fields = Loan::highlight_fields
   begin 
    @loan = Infusionsoft.data_load('Contact', loan_id, fields)
    Infusionsoft.contact_add_to_group(loan_id, 262) 
   rescue
     @error = true
   end   

 end
 
 
 
  def manual_shop_loan
    #abort("#{params}")
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != '54b0c58c7ce9f2a8b551351102ee0938'
      @error = true
      return
    end
    
   loan_id = params[:id]
   fields = Loan::highlight_fields
   begin 
    @loan = Infusionsoft.data_load('Contact', loan_id, fields)
    
    Infusionsoft.contact_add_to_group(loan_id, 381) 
    render plain: 'Success!'
    return
   rescue
     render plain: 'Error!'
     return
     #@error = true
   end   
    render plain: 'Not sure if it worked!'
 end
 
 
 def keep_loan
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != '54b0c58c7ce9f2a8b551351102ee0938'
      @error = true
      return
    end
   
   loan_id = params[:id]
   fields = Loan::highlight_fields
   begin 
    @loan = Infusionsoft.data_load('Contact', loan_id, fields)
    Infusionsoft.contact_add_to_group(loan_id, 264) 
   rescue
     @error = true
   end 
   
 end
 
 
 def indicate_interest
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != 'f69f936066aa90e241f3d0a8646c8107'
      @error = true
      return
    end
    
   loan_id = params[:id]
   fields = Loan::highlight_fields
   begin 
    @loan = Infusionsoft.data_load('Contact', loan_id, fields)
    if @loan['_LenderEmail'] == params[:email]
      Infusionsoft.contact_add_to_group(loan_id, 266) 
    else
      @denied = true
    end
   rescue
     @error = true
   end     

 end
 
 def declined_interest
    #return blank if the token doesn't match
    if params[:token].blank? || params[:token] != 'f69f936066aa90e241f3d0a8646c8107'
      @error = true
      return
    end

   loan_id = params[:id]
   fields = Loan::highlight_fields
   begin 
    @loan = Infusionsoft.data_load('Contact', loan_id, fields)
    if @loan['_LenderEmail'] == params[:email]
      Infusionsoft.contact_add_to_group(loan_id, 268) 
    else
      @denied = true
    end
   rescue
     @error = true
   end 

   
 end
   
  
  
  
  
  private
  def match_state(lender, state)
    if lender['_LendingStates0'] == 'Nationwide' 
      return 1
    end
    if !lender['_LendingStates0'].blank?
      lender['_LendingStates0'].split(',').each do |us_state|
        if Loan.states.has_key? us_state && state == us_state
          return 1
        end
      end
    end
    return 0
    
  end 
  
  
  def match_loan_type(lender, loanType)
    lender_loan_types = loan_type(lender)
    return (lender_loan_types.include? loanType) ? 1 : 0 
  end
  
  
  
  def match_net_amount(lender, net_amount)
    min = lender['_LoanMinDropDown'].to_i
    max = lender['_LoanMaxDropDown'].to_i
    
    if net_amount<max && net_amount>min
       return 1
    end
    return 0
    
  end

  def match_term_length(lender, term_length)
    output = 0
    if lender['_TermLengthType'] == 'month(s)'
      max = lender['_TermLengthMax'].to_i
      min = lender['_TermLengthMin'].to_i
    else
      max = lender['_TermLengthMax'].to_i*12
      min = lender['_TermLengthMin'].to_i*12
    end
      (term_length > min && term_length < max) ? output += 1 : nil
      (term_length > 24 && max > 24) ? output += 1 : nil
   
    return output
  end
  
  def match_ltv(lender, ltv)
    output = 0
    if ltv > 0
     output = (lender['_LoanToValueMax'].to_i > ltv) ? 1 : 0
    end
    return output
  end
  
  def match_time_in_business(lender)
    return lender['_TimeInBusiness'].to_f/10
  end
  
  def match_internal_rank(lender)
    return lender['_FDRanking'].to_f/10
  end
  
  def match_closes_rank(lender)
    return lender['_NumberOfClosedDeals'].to_f/10
  end







  def loan_type(loan)
    case loan['_LendingCategory']
      when 'Private Real Estate Loan'
        return loan['_LendingTypes']
      when 'Business Financing'
        return loan['_BusinessFinancingTypes']
      when 'Equity and Crowdfunding'
        return loan['_EquityandCrowdFunding']
      when 'Residential or Commercial Mortgage'
        return loan['_MortageTypes']
    end
  end  


  
  
end
