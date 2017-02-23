class Note
  include MongoMapper::Document
  key :user_id, String
  key :content, String
  key :email, String
  key :lender_id, String
  key :loan_id, String
  key :date_added, String

  def user
    User.find_by_id(self.user_id)
  end
end