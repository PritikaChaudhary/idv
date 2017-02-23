class FolderFile
  include MongoMapper::Document
  key :custom_folder_id, :required=>true
  key :user_id, String
  key :loan_id, Integer
  key :name, String
  key :hide, Integer
  key :delete, Integer
end