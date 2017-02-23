class LoanEmail
  include MongoMapper::Document
  key :body, String
  key :from, String
  key :to, String
  key :subject, String
  key :file_name, String
  key :read_status, Integer
end