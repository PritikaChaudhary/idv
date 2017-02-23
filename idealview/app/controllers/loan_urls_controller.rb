class LoanUrlsController < ApplicationController

  def index
    render plain: 'this is the index'
  end
  
  def show
    @url = LoanUrl.find_by_url(params[:id])
  end
  
  def create
    if params[:loan_id]
      @loan = Loan.find_by_id(params[:loan_id].to_i)

      loan_url = LoanUrl.new
      loan_url.loan_id = params[:loan_id].to_i
      loan_url.email = params[:email]
      loan_url.name = params[:name]
      loan_url.user_id = current_user.id
      loan_url.init_url
      # abort("#{loan_url.inspect}")
      if loan_url.save
        # LoanUrlMailer.email_share_link(loan_url).deliver
        
        @numoflenders = LoanUrl.count(:user_id => current_user.id)
        @num_of_loans = LoanUrl.all(:loan_id => params[:id].to_i)
        @num =  @num_of_loans.count
        
        if current_user.max_lenders != "No Limit" &&  @adminLogin == false
          @share_lender = "no"
          @share_lenders = LoanUrl.all(:user_id => current_user.id)
        else
          @share_lender = "yes"
        end
        flash.now[:notice] = "URL was added."
        render partial: 'loans/loan_url_forms'
      else
         flash.now[:alert] = "All fields are required and the email must be valid."
         render partial: 'loans/loan_url_forms'
      end
    else
      render plain: 'that did not work'
    end
  end


  def destroy
    if params[:id]
      loan_url = LoanUrl.find_by_id(params[:id])
      @loan = loan_url.loan
      if loan_url.delete
          flash.now[:notice] = "Access was removed."
          render partial: 'loans/loan_url_forms'
      else
         flash.now[:alert] = "Something went wrong. Access was not removed."
         render partial: 'loans/loan_url_forms'
      end 
    end      
  end


  def email_link
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

   def generate_url
      @loan = Loan.find_by_id(params[:id].to_i)
      id = @loan.id
      l_id = "#{id}" 
      enc = Base64.encode64(l_id)
      enc2 = Base64.encode64(enc)
      @show_prompt="yes"
      if @loan
       @loan.doc_url = enc2
       @loan.url_time = Time.now.getutc
       @loan.save
       flash.now[:notice] = "Link has been generated."
      end 
        render partial: 'loans/loan_url_form'   
   end

   
   def extend_date
     @loan = Loan.find_by_id(params[:id].to_i)
     if @loan
      time = @loan.url_time
      url_month = time.month
      url_year = time.year
      now_time = Time.now
      now_month = now_time.month
      now_year = now_time.year
      
      valid_url_time = 0
      if url_year < now_year
        valid_url_time = 1
      else
        if url_month < now_month
          valid_url_time = 1
        end
      end

      if valid_url_time != 1
        if time.month == 12
          next_month = Time.utc(time.year+1, 1, time.day)
        else
          next_month = Time.utc(time.year, time.month+1, time.day)
        end
      else
        next_month =  Time.now + 1.month
      end

      @loan.url_time = next_month
      @loan.save
      flash.now[:notice] = "Validity date has been extended."
     end
     render partial: 'loans/loan_url_form'
   end

  def save_status
    lender=LoanUrl.find(params[:id])
    lender.status=params[:status]
    lender.save
    render nothing: true
  end

  def fetch_lenders
    @lenders =Loan.find_by_id(params[:id].to_i)
    render partial: 'loans/lender_records'

  end

end