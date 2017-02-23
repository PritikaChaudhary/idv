class NewCustomField
  include MongoMapper::Document
  key :name, String
  key :field_name, String
  key :value, String
  key :user_id, String
  key :hide, Integer
  key :required, Integer
end