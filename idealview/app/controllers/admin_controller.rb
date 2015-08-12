class AdminController < ApplicationController

  def index
    @users = User.all
    #usr = User.find_by_email("lloveland@cacheprivatecapital.com")
    #usr.password= "12345678"
    #usr.save
    #abort("#{usr.inspect}")
    authorize User
  end
  


 def new_user
   #string = (0...8).map { (65 + rand(26)).chr }.join
   #abort("#{string}")
   @user = User.new
   authorize @user
 end
 
 
 def edit_user
     @user = User.find(params[:id])
     authorize @user
 end 
 
 
 def create_user
    #abort("#{params[:user]}")
    user_info=params[:user] 
    roles=params[:roles]
    unless roles['Broker'].blank?
      broker = Broker.new
      broker.name = user_info['name']
      broker.email = user_info['email']
      broker.password = user_info['password']
      broker.save
      broker_id=broker.id
    end
    #abort("#{params}")
    @user = User.new(params[:user])
    authorize @user
    
    @user.password_confirmation = @user.password
    
    @roles = Array.new
    if !params[:roles].blank?
      params[:roles].each do |item|
        @roles.push(Role.new(:name=>item[1]))
      end
    end

    @user.roles = @roles

    unless broker_id.blank?
      @user.broker_id = broker_id
    end
    
    if @user.save :safe => true
      unemail = user_info['email'].split("@")[0]
      uemail = unemail.gsub!(/[^0-9A-Za-z]/, '')
      bucket_name = @user.id.to_s+uemail.to_s 
      bucket = S3.create_bucket(bucket: bucket_name)
      @user.bucket_name = bucket_name
      @user.save
      flash[:notice] = @user.email + " Created Successfully"
    else
     flash[:alert] = "Something went wrong! You may need a longer password. Please try again."
     redirect_to action: 'new_user'
     return
    end
    
    redirect_to action: 'index'

 end
 
 
 
 def update_user
    @user = User.find(params[:id])

    @roles = Array.new
    if !params[:roles].blank?
      params[:roles].each do |item|
        @roles.push(Role.new(:name=>item[1]))
      end
    end
    @user.roles = @roles
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
    end
    
    @user.attributes= params[:user].except(:roles)

    if @user.save :safe =>true, :validate => false

      flash[:notice] = @user.email + " Updated Successfully"
      redirect_to action: 'index'
      return
    else
      flash[:alert] = "Something went wrong! Try Again."
      render 'edit_user'
      return
    end
 end 

 
 def destroy_user

  @user = User.find(params[:id])

  unless @user.broker_id.blank?
    @broker=Broker.find(@user.broker_id)
    @broker.delete=1
    @broker.save
  end

  authorize @user
  if @user.destroy
      flash[:notice] = @user.email + " Removed Successfully"
      redirect_to action: 'index'    
  else
      flash[:alert] = 'Something went wrong! Please try agian.'
      redirect_to action: 'index'    
  end   
 end
 
 

 
 
end




