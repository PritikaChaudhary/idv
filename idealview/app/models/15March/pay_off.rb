class PayOff
  include MongoMapper::Document
  key :copy_loan_id, :required=>true
  key :amount, String
  key :recipient, String
end