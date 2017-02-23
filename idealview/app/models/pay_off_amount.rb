class PayOffAmount
  include MongoMapper::Document
  key :amount, String
  key :recipient, String
  key :loan_id, Integer
  key :payids, Integer
end