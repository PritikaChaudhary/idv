class ShopGroup
  include MongoMapper::Document
  key :name, String
  key :created_by, String
  key :created_date, String 

  def user
    User.find_by_id(self.created_by)
  end

 

end