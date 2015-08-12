class EmailsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def index
    #email = Email.new
    #email.name = "Thanking you email to subscribe plan"
    #email.subject = "Thanking you for subscribing plan_name"
   # email.subject = "New FD Loan Submission"
    #email.content = "<p> Thank you for subscribing to idealview plan_name! We are excited to help you organize and share better, faster deals with your lenders.  </p><br> You now have access to all the features of the Pro Plan."
    #email.fixed_variable = "plan_name"
    #email.save
    @emails = Email.all
  end

  def update_email
    email = Email.find(params[:id])
    email.content = params[:content]
    email.subject = params[:subject]
    email.save
    @emails = Email.all
    render partial: 'emails/emails'
  end
  
  
end
