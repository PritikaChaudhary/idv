class CreditReport
  include MongoMapper::Document
  key :credit_info_id, String
  key :borrower_id, String
  key :report, String
  
end