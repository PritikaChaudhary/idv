class Plan
  include MongoMapper::Document
  key :plan_id, String
  key :name, String
  key :amount, String
  key :currency, String
  key :interval, String
end