class FolderFile
  include MongoMapper::Document
  key :custom_folder_id, :required=>true
  key :user_id, String
  key :loan_id, Integer
  key :name, String
  key :dropbox_name, String
  key :url, String
  key :hide, Integer
  key :delete, Integer
  key :from, String
  key :file_size, Float
  key :file_of, String

  def folder_name
    foldr_name = CustomFolder.find_by_id("#{self.custom_folder_id}")
    return "#{foldr_name.folder_name}"

  end
end	 		