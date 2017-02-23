class CustomField
  include MongoMapper::Document
  key :custom_id, String
  key :field_name, String
  key :hide, Integer
  key :required, Integer
end