class Collateral
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :address, String
  key :city, String
  key :state, String
  key :postalcode, String
  key :estimated_value, String
  key :amount_owed, String
  key :mortgage_status, String
  key :gross_monthly_income, String
  key :purchase_price, String
end