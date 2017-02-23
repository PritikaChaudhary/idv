class AdminController < ApplicationController

  def index
    # uses = User.all
    # uses.each do |use|
    #   roles=use.roles
    #   roles.each do |role|
    #     if role.name=="Admin"
    #       use.is_admin=true
    #     end
    #   end
    #   use.save
    # end
    # uInfo = User.find_by_email("pritika26@digimantra.com");
    # abort("#{uInfo.inspect}")
    


    @users = User.all(:is_admin => true)
    # abort("#{@users}")
    authorize User
  end
  


 def new_user
   @user = User.new
    authorize @user
 end
 
 
 def edit_user
     @user = User.find(params[:id])
     authorize @user
 end 
 
 
 def create_user

    # abort("#{params}")
    user_info=params[:user] 
    roles=params[:roles]
    uInfo = User.find_by_email("#{user_info['email']}")
    if uInfo.blank?
      
      unless roles['Broker'].blank?
        broker = Broker.new
        broker.name = user_info['name']
        broker.email = user_info['email']
        broker.password = user_info['password']
        broker.save
        broker_id=broker.id
      end
     

      @user = User.new(params[:user])

      # authorize @user
      # abort("#{@user.inspect}")
      
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
      @user.is_admin = true
      usrname = user_info['username'].downcase
      @user.username = usrname.gsub(' ','')
      uname = usrname.gsub(' ','')
      sub_domain =  uname.gsub(/[^0-9A-Za-z]/, '')
      @user.subdomain = sub_domain
      @user.user_password = user_info['password']
      @user.password = "#{user_info['password']}"
     
      
      if @user.save :safe => true
       LoanUrlMailer.admin_credentials("#{@user.id}").deliver
       flash[:notice] = @user.email + " Created Successfully"
      else
       flash[:alert] = "Something went wrong! You may need a longer password. Please try again."
       redirect_to action: 'index'
       return
      end
    end
    
    redirect_to action: 'index'

 end
 
 
 def download_csv_admin
    @users = User.all(:is_admin => true)
    filename="admin_"+Time.now.strftime("%m%d%y%H%M%S")
    save_path = Rails.root.join('csvs',filename+'.csv')
    CSV.open(save_path, "wb") do |csv|
      csv << ["Name", "Email"]
      @users.each do |user|
        csv << ["#{user.name}", "#{user.email}"]
      end
    end
    send_file 'csvs/'+filename+'.csv', :type => 'text/csv'
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
 
 def settings
      @user=User.find_by_id(current_user.id)
      #abort("#{@user.inspect}")
     # @broker=Broker.find_by_email(current_user.email)
      #abort("#{current_user.email}")
  end
 
  def update
    @user = User.find_by_email(params[:email])
    #abort("#{@user.inspect}")
    @user.system_email = params[:system_email]
    @user.name = params[:name]
    if @user.save
     redirect_to action: 'settings'
    end
  end

  def delete_admins
    ids=params[:moredata].split(",")
    require "stripe"
     Stripe.api_key = "sk_test_rL51BkW2eNDeonJ6mn5LsW6q"
    ids.each do |number|
      #abort("#{brokerRecord.inspect}")
      user = User.find(number)
      unless user.blank? 
        User.delete(user.id)
        if defined? user.customer_id
          if user.customer_id != nil
            cu = Stripe::Customer.retrieve(user.customer_id )
            cu.delete
          end
        end
      end
   end 
    @users = User.all(:is_admin => true)  
    flash.now[:notice] = "Brokers deleted successfully"
    render partial: 'admin/all_admins'
  end

  def check_email
    users = User.find_by_email(params[:email])
    if users.blank?
      @rsp = "yes"
    else
      @rsp = "no"
    end
    render plain: @rsp
  end

  def check_uname
    usrname = params[:username].downcase
    usrname = usrname.gsub(' ','')
    users = User.find_by_username("#{usrname}")
    # abort("#{users.inspect}")
    if users.blank?
      @rsp = "yes"
    else
      @rsp = "no"
    end
    render plain: @rsp
  end
 
end




