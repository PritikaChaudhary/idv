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
  key :email, String,   :required => true
  key :encrypted_password, String,   :required => true
  key :current_sign_in_at, String
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
  key :plan, String
  key :subscription, String
  key :system_email, String
  key :ids_config, Integer
  key :ids_username, String
  
  attr_accessible :name,:email, :password, :password_confirmation, :remember_me, :encrypted_password, :roles
  
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
  
  
end
