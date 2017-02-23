class CreditInfo
  include MongoMapper::Document
  key :loan_id, Integer
  key :borrower_id, String
  key :firstname, String
  key :middlename, String
  key :lastname, String
  key :ein, Integer
  key :address, String
  key :city, String
  key :state, String
  key :postal_code, String
  key :personal_form_status, Integer
  key :payment_form_status, Integer
  key :card_number, String
  key :card_name, String
  key :card_address, String
  key :card_city, String
  key :card_state, String
  key :card_postalcode, String
  key :expiry_date, String
  key :payment_form, Integer
end