class LoanUrlMailer < ActionMailer::Base
  add_template_helper(FdCustomHelper)
  default from: "deals@fundingdatabase.com"
  
  def email_link(loan_url)
    @loan_url = loan_url
    @loan = @loan_url.loan
    @email = Email.find_by_name("New deal for review")
    emails = [loan_url.email]
    mail(to: emails, subject: @email.subject)
 end

 def email_share_link(loan_url)
    @loan_url = loan_url
    @loan = @loan_url.loan
    @email = Email.find_by_name("New deal for review")
    emails = [loan_url.email]
    mail(to: emails, subject: @email.subject)
 end

 def email_pdf(pdfInfo, email)
    lender = LoanUrl.find_by_email(email)
    if lender.blank?
      @name="Hello"
    else
       @name=lender.name   
    end
    @pdfInfo = pdfInfo
    today_date=Date.today.strftime("%b, %Y")
    emails = [email]
    @email = Email.find_by_name("New summaries to consider")
    email_subject = @email.subject.gsub("today_date", today_date)
    #attachments[@pdfInfo.file_name+'.pdf'] = File.read("#{Rails.root}/pdfs/"+@pdfInfo.file_name+".pdf")  
    mail(to: emails, subject: email_subject)
  end

  def email_broker(broker)
    @bemail = broker.email
    @password = broker.password
    emails = broker.email
    @email = Email.find_by_name("Broker Login")
    mail(to: emails, subject: @email.subject)
  end

  def request_access(broker_email, access_id)
    @broker_email = broker_email
    sub_broker = Broker.find_by_id(access_id)
    @access_email = sub_broker.email
    @broker = Broker.find_by_email(@broker_email)
    emails = sub_broker.email
    @broker_id = @broker.id
    @sub_broker_id = sub_broker.id
    @email = Email.find_by_name("Request Access")
    mail(to: emails, subject: @email.subject)
  end

  def complete_loan(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
    @borrowers = @loans.borrower
    @collaterals = @loans.collateral
    @funds = @loans.use_of_fund
    @email = Email.find_by_name("New FD Loan Submission")
    @sub = "#{@email.subject} $#{@loans.info['_NetLoanAmountRequested0']}"
    emails = @email.to
    # abort("#{@email.inspect}")
    mail(to: emails, subject: @sub)
  end

  def incomplete_loan(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
    @loans.incomplete = 1
    @loans.save
    @email = Email.find_by_name("Incomplete Submissions")
    # emails = "admin@fundingdatabase.com"
    emails = @email.to
    mail(to: emails, subject: @email.subject)
  end

   def new_plan(plan, email)
    @plan = plan 
    emails = email
    @email = Email.find_by_name("Thanking you email to subscribe plan")
    email_subject = @email.subject.gsub("plan_name", plan)
    #emails = "pritika@digimantra.com"
    mail(to: emails, subject: email_subject)
  end

  def thankyou_fdLoan(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
     @link = "<a href='http://dash.idvstage.us/loans/docs/#{@loans.doc_url}'>http://dash.idvstage.us/loans/docs/#{@loans.doc_url}</a>"
    @email = Email.find_by_name("Thanking you email for fundingdatabase loans")
    emails = @loans.email
    #emails = "pritika@digimantra.com"
    mail(to: emails, subject: @email.subject)
  end

  def thankyou_email(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
    unless @loans.info['FirstName'].blank?
     @name = @loans.info['FirstName']
     unless @loans.info['LastName'].blank?
      @name = "#{@loans.info['FirstName']} #{@loans.info['LastName']}"
     end
    else
      @name="Hello"
    end
    @email = Email.find_by_name("Thanking you email for IDV loan.")
    emails = @loans.email
    #emails = "pritika@digimantra.com"
    mail(to: emails, subject: @email.subject)
  end

   
   def welcome_email(broker_id)
    id = broker_id
    @broker = Broker.find_by_id(id)
    @name = @broker.name
    @emailz = @broker.email
    @password = @broker.password
    @plan = @broker.plan
    @email = Email.find_by_name("Welcome email")
    emails = @broker.email
    #emails = "pritika@digimantra.com"
    mail(to: emails, subject: @email.subject)
  end

  def shop_loan(loan_id)
    @loan = CopyLoan.find_by_id("#{loan_id}")
    @link = "http://dash.idvstage.us/loans/shop_loan/#{@loan.id}"
    @email = Email.find_by_name("Round Robin")
    mail(to: @email.to, subject: @email.subject)
  end

  def reject_loan(loan_id)
    @loan = CopyLoan.find_by_id("#{loan_id}")
    @loan_name = @loan.name
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Reject Shop Loan")
    mail(to: user.email, subject: @email.subject)
  end

  def email_lender(broker)
    @bemail = broker.email
    @password = broker.password
    if broker.email == "preet@digimantra.com" 
      emails = "pritika@digimantra.com"
    elsif broker.email == ""
      emails = "pritika@digimantra.com"
    elsif broker.email.blank?
      emails = "pritika@digimantra.com"
    else
      emails = broker.email
    end
    @email = Email.find_by_name("Lender Login")
    mail(to: emails, subject: @email.subject)
    
  end

  def lender_shop_loan(id)
    @info  = LoanLender.find_by_id(id)
    @amnt = "$#{@info.copy_loan.info['_NetLoanAmountRequested0']}"
    @link = "http://dash.idvstage.us/lenders/loan_detail/#{@info.id}"
    emails = @info.lender.email
    @email = Email.find_by_name("Lender Shop Loan")
    # emails = "pritika@digimantra.com"
     @subjct = @email.subject.gsub("loan_amount", @amnt)
    mail(to: emails, subject: @subjct)
    
  end

  def group_shop_loan(id)
    @info  = LoanLender.find_by_id(id)
    @amnt = "$#{@info.copy_loan.info['_NetLoanAmountRequested0']}"
    @link = "http://dash.idvstage.us/lenders/loan/#{@info.id}"
    emails = @info.lender.email
    @email = Email.find_by_name("Group Shop Loan")
    # emails = "pritika@digimantra.com"
     @subjct = @email.subject.gsub("loan_amount", @amnt)
    mail(to: emails, subject: @subjct)
    
  end

  def loan_accepted(lenderId)
    @lendr = LoanLender.find_by_id("#{lenderId}")
    @loan = CopyLoan.find_by_id("#{@lendr.copy_loan_id}")
    @loan_name = @loan.name
    if @lendr.lender.name.blank?
      @lender_name = "-"
    else
      @lender_name = @lendr.lender.name
    end
    if @loan.info['FirstName'].blank?
      @borrower_name = "-"  
    else
      @borrower_name =  @loan.info['FirstName']
    end
    if @loan.info['_BrokerName'].blank?
      @broker_name = "-"  
    else
      @broker_name = @loan.info['_BrokerName']
    end
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Loan Accepted")
    emails = "dpianoman@gmail.com"
    @subjct = @email.subject.gsub("loan_name", @loan_name)
    mail(to: emails, subject: @subjct)
  end

  def shop_loan_accepted(lenderId)
    @lendr = LoanLender.find_by_id("#{lenderId}")
    @loan = CopyLoan.find_by_id("#{@lendr.copy_loan_id}")
    @loan_name = @loan.name
    if @lendr.lender.name.blank?
      @lender_name = "-"
    else
      @lender_name = @lendr.lender.name
    end
    if @loan.info['FirstName'].blank?
      @borrower_name = "-"  
    else
      @borrower_name =  @loan.info['FirstName']
    end
    if @loan.info['_BrokerName'].blank?
      @broker_name = "-"  
    else
      @broker_name = @loan.info['_BrokerName']
    end
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Loan Accepted")
    emails = "dpianoman@gmail.com"
    # emails = "pritika@digimantra.com"
    @subjct = @email.subject.gsub("loan_name", @loan_name)
    mail(to: emails, subject: @subjct)
  end

  def loan_to_lender(lenderId)
    @lendr = LoanLender.find_by_id("#{lenderId}")
    @loan = CopyLoan.find_by_id("#{@lendr.copy_loan_id}")
    @loan_name = @loan.name
    
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Lender Accepted Email")
    emails = @lendr.lender.email
    @subjct = @email.subject.gsub("loan_name", @loan_name)
    mail(to: emails, subject: @subjct)
  end

  def shop_loan_to_lender(lenderId)
    @lendr = LoanLender.find_by_id("#{lenderId}")
    @loan = CopyLoan.find_by_id("#{@lendr.copy_loan_id}")
    @loan_name = @loan.name
    
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Lender Accepted Email")
    emails = @lendr.lender.email
    @subjct = @email.subject.gsub("loan_name", @loan_name)
    mail(to: emails, subject: @subjct)
  end

  def shop_loan_reminder(id, lender_id)
    @remindr = Reminder.find_by_id(id)
    @time_lft = "#{@remindr.num} #{@remindr.units}" 
    @lendr = LoanLender.find_by_id(lender_id)
    @loan_name = "#{@lendr.copy_loan.name}"
    uemail = @lendr.lender.email
    @email = Email.find_by_name("Reminder")
    email_subject = @email.subject.gsub("left_time", @time_lft)
    mail(to: uemail, subject: email_subject)
  end

  def test_email(id)
    @name = id
    mail(to: "pritika@digimantra.com", subject: @name)
  end

  def complete_this_loan(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
    @link = "http://fundingdatabase.com/loan-page/?id=#{@loans.fd_id}"
    unless @loans.info['FirstName'].blank?
      @contact_name = @loans.info['FirstName']
    else
      @contact_name = ""
    end
    @email = Email.find_by_name("Fund Loan")
    emails = @loans.email
    mail(to: emails, subject: @email.subject)
  end

   def fund_email(loanInfo)
    unless loanInfo.info['FirstName'].blank?
      @contact_name = loanInfo.info['FirstName']
    else
      @contact_name = ""
    end
    @link = "https://dash.idvstage.us/loans/edit_application/#{loanInfo.id}"
    @email = Email.find_by_name("Fund Loan")
    mail(to: loanInfo.info['Email'], subject: @email.subject)
  end

  # def form_link(loanInfo, email)
  #   @link = "https://dash.idvstage.us/loans/edit_loan/#{loanInfo.id}"
  #   @email = Email.find_by_name("Form Link")
  #   mail(to: email, subject: @email.subject)
  # end

  def form_link(subject, msg, email)
    # abort("#{subject},,, #{msg},,,, #{email}")
    @body = msg
    mail(to: email, subject: subject)
  end

   def sync_successfully(user_id)
    uinfo = User.find_by_id("#{user_id}")
    emails = uinfo.email
    # emails = "pritika@digimantra.com"
    mail(to: emails, subject: "Loans are Synced")
  end

  def send_marketplace(loan_id)
    @loan = MarketplaceLoan.find_by_id("#{loan_id}")
    @loan_name = @loan.name
    @uInfo = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Send to Marketplace")
    # abort("#{@email.inspect}")
    mail(to: @uInfo.email, subject: @email.subject)
  end

  def admin_credentials(uId)
    @user = User.find_by_id("#{uId}")
    # abort("#{@user.inspect}")
    @uemail = "#{@user.email}"
    @upassword = "#{@user.password}"
    @email = Email.find_by_name("Admin login credentials")
    # abort("#{@email.inspect}")
    mail(to: @uemail, subject: @email.subject)
  end

  def login_credentials(uId, type)
    @user = User.find_by_id("#{uId}")
    # abort("#{@user.inspect}")
    @uemail = "#{@user.email}"
    @upassword = "#{@user.password}"
    @utype = "#{type}"
    @email = Email.find_by_name("Login credentials")
    # abort("#{@email.inspect}")
    mail(to: @uemail, subject: @email.subject)
  end

  def send_loan_summary(id, pdf_link, uemail)
    @linfo  = Loan.find_by_id(id.to_i)
    # abort("#{@linfo.inspect}")
    @amnt = "$#{@linfo.info['_NetLoanAmountRequested0']}"
    @loan_name = "#{@linfo.name}"
    @pdf_link = pdf_link
    @email = Email.find_by_name("PDF Summary")
    rplc = {"loan_amount" => @amnt , "loan_name" => @loan_name}
    @subjct = @email.subject.gsub(/\w+/) { |m| rplc.fetch(m,m)}
    abort("#{@subjct}")
    mail(to: uemail, subject: @subjct)
    
  end
  
end