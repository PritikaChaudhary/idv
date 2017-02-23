class SyncLoan
  include MongoMapper::Document
  key :user_id, String
  key :status, Integer
  key :process, String
end