class ShopLoan
  include MongoMapper::Document
  key :loan_id, Integer
  key :broker_id, String
  key :user_id, String
  key :copy_loan_id, String
  key :shop_date, String
end