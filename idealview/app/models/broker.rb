class Broker
  include MongoMapper::Document
  include ActionView::Helpers

  many :loans

  key :infusion_id, Integer
  key :firstName, String
  key :lastName, String
  key :name, String
  key :company, String
  key :jobTitle, String
  key :streetAddress1, String
  key :streetAddress2, String
  key :city, String
  key :state, String
  key :postalCode, String
  key :country, String
  key :phone1, String
  key :phone2, String
  key :fax1, String
  key :email, String
  key :website, String
  key :address2Street1, String
  key :address2Street2, String
  key :city2, String
  key :state2, String
  key :postalCode2, String
  key :country2, String
  key :address3Street1, String
  key :address3Street2, String
  key :city3, String
  key :state3 , String
  key :postalCode3, String  
  key :country3, String
  key :password, String
  key :request_access, String
  key :request_permission , String
  key :email_status, Integer
  key :delete, Integer
  key :parent_broker, String
  key :parent_user, String
  key :permissions, String
  key :broker_admin, Integer
  key :customer_id, String

  

  def self.highlight_fields
   temp = [
       :Id,
       :FirstName,
       :LastName, 
       :Company, 
       :JobTitle,
       :StreetAddress1, 
       :StreetAddress2, 
       :City, 
       :State, 
       :PostalCode, 
       :Country, 
       :Phone1, 
       :Phone2, 
       :Fax1, 
       :Email, 
       :Website, 
       :Address2Street1, 
       :Address2Street2, 
       :City2, 
       :State2, 
       :PostalCode2, 
       :Country2, 
       :Address3Street1, 
       :Address3Street2, 
       :City3, 
       :State3 , 
       :PostalCode3,   
       :Country3, 
    ]
  end

end
