class CopyCollateralNoi
  include MongoMapper::Document
  key :copy_loan_id, String
  key :collateral_id, String
  key :value, String 
end