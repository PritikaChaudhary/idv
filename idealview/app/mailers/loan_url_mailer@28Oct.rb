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
    @email = Email.find_by_name("New FD Loan Submission")
    emails = "admin@fundingdatabase.com"
    #emails = "pritika@digimantra.com"
    mail(to: emails, subject: @email.subject)
  end

  def incomplete_loan(loan_id)
    id = loan_id.to_i
    @loans = Loan.find_by_id(id)
    @loans.incomplete = 1
    @loans.save
    @email = Email.find_by_name("Incomplete Submissions")
    emails = "admin@fundingdatabase.com"
    #emails = "pritika@digimantra.com"
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
     @link = "<a href='http://dash.idealview.us/loans/docs/#{@loans.doc_url}'>http://dash.idealview.us/loans/docs/#{@loans.doc_url}</a>"
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
    @link = "http://dash.idealview.us/loans/shop_loan/#{@loan.id}"
    @email = Email.find_by_name("Shop Loan")
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

  def loan_accepted(loan_id)
    @loan = CopyLoan.find_by_id("#{loan_id}")
    @loan_name = @loan.name
    user = User.find_by_id("#{@loan.user_id}")
    @email = Email.find_by_name("Loan Accepted")
    mail(to: user.email, subject: @email.subject)
  end

  def shop_loan_reminder(id, lender_id)
    @remindr = Reminder.find_by_id(id)
    @loan = "#{@remindr.num} #{@remindr.units}" 
    @lendr = LoanLender.find_by_id(lender_id)
    @link = @lender.id
    uemail = @lendr.lender.email
    @email = Email.find_by_name("Reminder")
    mail(to: uemail, subject: @email.subject)
  end

end