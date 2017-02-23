class Image
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :file_id, ObjectId
  key :name, String
  key :src, String
  key :data, String
  key :featured, Boolean, :default => false
  key :url, String
  belongs_to :loan
end