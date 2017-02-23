class CollateralNoi
  include MongoMapper::Document
  key :loan_id, Integer
  key :collateral_id, String
  key :value, String 
end