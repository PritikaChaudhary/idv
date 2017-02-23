class MarketPlace
  include MongoMapper::Document
  key :loan_id, Integer
  key :user_id, String
  key :created_date, String
  key :type, String
  key :access_id, String 
  # one :loan, :in => :loan_id

  def loan
    Loan.find_by_id(self.loan_id)
  end

  def access
  	unless self.access_id.blank?
    	MarketAccess.find_by_id(self.access_id)
  	end	
  end
end