class TermCondition
  include MongoMapper::Document
  key :header, String
  key :second_header, String
  key :content, String
  key :type, String
end