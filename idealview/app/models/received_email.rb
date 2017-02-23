class ReceivedEmail
  include MongoMapper::Document
  key :from, String
  key :to, String
  key :subject, String
  key :content, String
end