class LenderAgreement
  include MongoMapper::Document
  key :header, String
  key :content, String
  key :added_by, String 
  key :added_date, String

  def user
  	User.find_by_id(self.added_by)
  end
end