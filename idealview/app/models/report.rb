class Report
  include MongoMapper::Document
  key :transaction_id, String
  key :loan_id, String
  key :collateral_id, String
  key :api_key, String
  key :sitelynx_id, String
  key :client_id, String
end