class CopyBorrower
  include MongoMapper::Document
  key :copy_loan_id, :required=>true
  key :loan_id, Integer
  key :sort_id, Integer
  key :previous_sort_id, Integer
  key :borrower_type, String
  key :personal_name, String
  key :personal_phone, String
  key :personal_email, String
  key :personal_address, String
  key :personal_city, String
  key :personal_state, String
  key :personal_postalcode, String
  key :personal_monthly_income, String
  key :personal_dob, String
  key :personal_ein, String
  key :personal_ssn, String
  key :personal_gross, String
  key :personal_cashContribution, String
  key :personal_income_source, String
  key :income_how_long, String
  key :estimated_fico, String
  key :net_worth, String
  key :ever_borrow_money, String
  key :borrower_guarantor, String
  key :bio, String
  key :business_name, String
  key :business_phone, String
  key :business_address, String 
  key :business_city, String
  key :business_state, String
  key :business_postalcode, String
  key :business_type, String
  key :business_balance_sheet, String
  key :time_in_business, String
  key :state_of_incorporation, String
  key :revenue_time_period, String
  key :business_ein, String
  key :cash_on_hand, String
  key :est_fico, String
  key :available_credit, String
  key :monthly_noi, String
  key :annual_noi, String 
  key :account_recievable, String
  key :account_payable, String
  key :balance_sheet, String
  key :guarantor_name, String
  key :guarantor_phone, String
  key :guarantor_email, String
  key :guarantor_address, String
  key :guarantor_city, String
  key :guarantor_state, String
  key :guarantor_postalcode, String
  key :guarantor_monthly_income, String
  key :guarantor_income_source, String
  key :guarantor_income_how_long, String
  key :guarantor_birthday, String
  key :guarantor_ssn, String
  key :guarantor_estimated_ficco, String
  key :guarantor_net_worth, String
  key :guarantor_borrow_money, String
  key :hide, Integer
  key :hide_fields, String

end