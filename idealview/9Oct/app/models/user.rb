class User
  include MongoMapper::Document
  include ActionView::Helpers
  include ActiveModel::SecurePassword
  attr_accessor :remember_token
  #def loginuser 
   # my_db = Settings.usercfg['settings']['db']
    # connection(Mongo::Connection.new('localhost', 27017))
    #set_database_name "#{my_db}"
  #end
  #abort("#{Settings.currentuser}")
   # connection(Mongo::Connection.new('localhost', 27017))
   # abort("#{@user_config}")
  # set_database_name "#{@user_config['settings']['db']}"
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
   #has_secure_password
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  many :roles
  many :messages
  


  key :name, String
  key :email, String,   :required => true
  key :encrypted_password, String,   :required => true
  key :current_sign_in_at, String
  key :last_sign_in_at, String
  key :current_sign_in_ip, String
  key :last_sign_in_ip, String
  key :sign_in_count, Fixnum
  key :remember_created_at, String
  key :is_admin, Boolean
  key :reset_password_token
  key :reset_password_sent_at
  key :broker_id, String
  key :customer_id, String
  key :bucket_name, String
  key :plan, String
  key :subscription, String
  key :system_email, String

  attr_accessible :name,:email, :password, :password_confirmation, :remember_me, :encrypted_password, :roles
  

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

  # def self.authenticate (email, password)
  #  user = find_by_email(email)
  #   if user && user.encrypted_password == BCrypt::Engine.hash_secret(password, user.encrypted_password)
  #       user
  #   else
  #     nil
  #   end
  # end

  #  def remember
  #   #self.remember_token = User.new_token
  #   #update_attribute(:remember_digest, User.digest(remember_token))
  #   end

  # # Returns a random token.
  # def User.new_token
  #   SecureRandom.urlsafe_base64
  # end


  
  
end
