class Message
  include MongoMapper::Document
  # key :user_id, :required=>true
  key :name, String
  key :body, String
  key :to, String
  key :subject, String
  key :from, String
end