class Document
  include MongoMapper::Document
  key :file_id, ObjectId
  key :loan_id, :required=>true
  key :user_id, String
  key :name, String
  key :category, String
  key :hide, Integer
  key :delete, Integer
  key :url, String
  key :from, String
  key :file_size, Float
end