class CustomSessionsController < ApplicationController
  before_filter :before_login, :only => :create
  after_filter :after_login, :only => :create

  def before_login
  end

  def after_login
    abort("#{current_user}")
  end
end
