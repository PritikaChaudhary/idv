class PaymentsController < ApplicationController
  ActionController::Base.helpers
  include ActionView::Helpers::NumberHelper
  require 'date'




  def select_plan
    require "stripe"
    Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"
    plans = Stripe::Plan.all
    
    plans.each do |plan|
      planInfo = Plan.find_by_plan_id(plan.id)
      if planInfo.blank?
        new_plan = Plan.new
        new_plan.plan_id = plan.id
        new_plan.name = plan.name
        new_plan.amount = plan.amount
        new_plan.currency = plan.currency
        new_plan.interval = plan.interval
        new_plan.save
      else
        planInfo.plan_id = plan.id
        planInfo.name = plan.name
        planInfo.amount = plan.amount
        planInfo.currency = plan.currency
        planInfo.interval = plan.interval
        planInfo.save
      end
    end
    
    @all_plans = Plan.all

    #abort("#{@infoBroker.inspect}")
 
 end

 def payment_successfull
    require "stripe"
    Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"

    broker = Stripe::Customer.create(
      :description => "Brokers",
      :source => params[:stripeToken],
      :email => params[:email],
      :plan => params[:plan]
    )

    if broker
      user = User.find_by_id(params[:user_id])
      user.customer_id = broker.id
      user.save

      brokr = Broker.find_by_id(params[:broker_id])
      brokr.customer_id = broker.id
      if brokr.save

      #LoanUrlMailer.new_plan(params[:plan], params[:email]).deliver
      #abort("#{broker.id}")
        redirect_to action: 'select_plan', id: params[:id]
      end
    end
 end
  
  
end
