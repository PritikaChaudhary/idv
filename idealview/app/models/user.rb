
class User
  include MongoMapper::Document
  include ActionView::Helpers
  #connection(Mongo::Connection.new('localhost', 27017))
  #set_database_name "new_db"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  many :roles


  key :name, String
  key :email, String, :required => true, :unique => true
  key :encrypted_password, String,   :required => true
  key :current_sign_in_at, String
  key :phone, String
  key :password, String
  key :last_sign_in_at, String
  key :current_sign_in_ip, String
  key :last_sign_in_ip, String
  key :sign_in_count, Fixnum
  key :remember_created_at, Time
  key :is_admin, Boolean
  key :reset_password_token
  key :reset_password_sent_at
  key :broker_id, String
  key :customer_id, String
  key :bucket_name, String
  key :username, String,   :required => true, :unique => true
  key :subdomain, String,   :required => true
  key :plan, String
  key :account, String
  key :subscription, String
  key :subscription_id, String
  key :expand_memory, Integer
  key :system_email, String
  key :ids_config, Integer
  key :ids_username, String
  key :with_recurly, Integer
  key :user_password, String
  key :cpc_username, String
  key :cpc_token, String
  key :cpc_email, String
  key :cpc_status, String
  key :cpc_password, String
  key :cpc_subdomain, String
  key :dropbox_accesstoken, String
  key :max_users, String
  key :max_lenders, String
  key :num_lenders, Integer
  key :max_storage, String
  key :int_storage, Integer
  key :max_upload, String
  key :int_upload, Integer
  key :pipelines, Integer
  key :req_docs, Integer
  key :loan_application_links, Integer
  key :forward_email, Integer
  key :market_access, Integer
  key :sub_users, Integer
  key :analysis_tab, Integer

  

  
  attr_accessible :name,:email, :username, :password, :password_confirmation, :remember_me, :encrypted_password, :roles
  
  # def self.authenticate(username_or_email, login_password)
  #  user = User.find_by_email(username_or_email)
  #   if user && user.match_password(login_password)
  #     return user
  #   else
  #     return false
  #   end
  # end
  # def match_password(login_password="")
  # encrypted_password == BCrypt::Engine.hash_secret(login_password, encrypted_password)
  # end


  def role?(role)
    
    if self.is_admin
       return true
    end
      
    self.roles.each do |item|
      if item.name.to_s == role.to_s
        return true
      end
    end
    
    return false
  end
  
  def roles_text
    @output = ''
    self.roles.each do |item|
      @output << item.name+', ' 
    end
    return @output
  end
 
 
  def self.valid_roles
    return ['Admin', 'Broker', 'Lender']
  end 

  def dropbox
    DropboxToken.find_by_user_id("#{self.id}")
  end

  def broker
    Broker.find_by_email("#{self.email}")
  end

  def count_users
    Broker.count(:parent_user => "#{self.id}")
  end

  def share_lenders
    LoanUrl.count(:user_id => self.id)
  end
  
  def memory
    
    begin
      image_sizes = Image.where(:user_id => "#{self.id}").fields(:file_size).all
      size = 0
      @size_arr = Array.new
      unless image_sizes.blank?
        image_sizes.each do |isize|
          @size_arr << isize.file_size.to_f
        end  
      end

      doc_sizes = Document.where(:user_id => "#{self.id}").fields(:file_size).all
      unless doc_sizes.blank?
        doc_sizes.each do |dsize|
          @size_arr << dsize.file_size.to_f
        end
      end

      file_sizes = FolderFile.where(:user_id => "#{self.id}").fields(:file_size).all
      unless file_sizes.blank?
        file_sizes.each do |fsize|
          @size_arr << fsize.file_size.to_f
        end
      end

      unless @size_arr.blank?
          
          total = @size_arr.inject(0, :+)
          total = total.round(2)
         
      else
        total = 0
      end
      # abort("#{total}")
      rescue Exception => exc
      if exc.message
        total = 0
      end

    end
    # abort("#{image_sizes.inspect} #{doc_sizes.inspect} #{file_sizes.inspect}")
    return total 

  end
  
end
