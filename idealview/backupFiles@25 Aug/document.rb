class Document
  include MongoMapper::Document
  key :file_id, ObjectId
  key :loan_id, :required=>true
  key :name, String
  key :category, String
  key :hide, Integer
  key :delete, Integer
end