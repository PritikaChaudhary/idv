class Image
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :user_id, String
  key :file_id, ObjectId
  key :name, String
  key :dropbox_name, String
  key :src, String
  key :data, String
  key :featured, Boolean, :default => false
  key :url, String
  key :from, String
  key :file_size, Float
  key :top, String
  key :left, String
  key :width, String
  key :height, String
  
  belongs_to :loan
end