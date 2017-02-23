class HomeController < ApplicationController
  def index
  	unless current_user.blank? 
	  	roles=current_user.roles
	    @names = Array.new
	    roles.each do |role|
	      @names << role.name
	    end

	    @checkAdmin = @names.include?('Admin')
	    @checkBroker = @names.include?('Broker')
	  	
	end
  end

  def broker_check
  	
  end
  
  def test
    @contact = Infusionsoft.data_load('Contact', 925, [:FirstName, :LastName])
  end
end
