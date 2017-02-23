class MarketplaceLoan
  include MongoMapper::Document
  include ActionView::Helpers

  key :loan_id, Integer
  key :user_id, String
  key :name, String
  key :type, String
  key :info, Object
  key :created_date, String
  key :created_by, String
  key :type, String
  key :access_id, String 
  key :status, Integer 
  key :hide_fields, String
 
  
  def loanInfo
    Loan.find_by_id(self.loan_id)
  end

  def access
    unless self.access_id.blank?
      MarketAccess.find_by_id(self.access_id)
    end 
  end



end
