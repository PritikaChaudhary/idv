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


end