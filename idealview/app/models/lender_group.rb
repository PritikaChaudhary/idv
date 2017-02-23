class LenderGroup
  include MongoMapper::Document
  key :group_id, String
  key :lender_id, String
  key :shop_loan_id, String
  key :status, String 

  def lender 
  	Lender.find_by_id(self.lender_id)
  end

  def copy_loan 
  	CopyLoan.find_by_id(self.shop_loan_id.to_s)
  end
end