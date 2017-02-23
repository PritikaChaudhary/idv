class Note
  include MongoMapper::Document
  key :user_id, String
  key :pdf, String
end