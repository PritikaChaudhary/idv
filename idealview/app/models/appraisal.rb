class Appraisal
  include MongoMapper::Document
  key :loan_id, Integer
  key :collateral_id, String
  key :user_id, String
  key :plan, String
  key :subscription_id, String
  key :appraisal_id, String
  key :file_id, String
  key :success, String
end