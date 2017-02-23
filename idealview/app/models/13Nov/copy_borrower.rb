class CopyBorrower
  include MongoMapper::Document
  key :copy_loan_id, :required=>true
  key :loan_id, Integer
  key :personal_name, String
  key :personal_phone, String
  key :personal_email, String
  key :personal_address, String
  key :personal_city, String
  key :personal_state, String
  key :personal_postalcode, String
  key :personal_dob, String
  key :personal_ein, String
  key :personal_ssn, String
  key :personal_gross, String
  key :personal_cashContribution, String
  key :bio, String
  key :business_name, String
  key :business_phone, String
  key :business_address, String	
  key :business_city, String
  key :business_state, String
  key :business_postalcode, String
  key :time_in_business, String
  key :revenue_time_period, String
  key :business_ein, String
  key :cash_on_hand, String
  key :est_fico, String
  key :available_credit, String
  key :monthly_noi, String
  key :annual_noi, String	
  key :account_recievable, String
  key :account_payable, String
end