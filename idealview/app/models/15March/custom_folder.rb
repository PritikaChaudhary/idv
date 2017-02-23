class CustomFolder
  include MongoMapper::Document
  include ActionView::Helpers
  many :folder_files

  key :loan_id, Integer
  key :user_id, String
  key :folder_name, String
  key :hide, Integer
  key :delete, Integer

  def files_by_folder loan_id
    FolderFile.find_all_by_custom_folder_id_and_loan_id(self._id.to_s, loan_id)
  end
 
end