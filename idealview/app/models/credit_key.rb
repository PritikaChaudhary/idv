class CreditKey
  include MongoMapper::Document
  key :user_id, String
  key :username, String
  key :password, String
end