class PriorityLoan
  include MongoMapper::Document
  include ActionView::Helpers

  key :loan_id, String
  key :user_id, String
  key :sort_order, Integer
  

  def loan_info
    Loan.find_by_id(self.loan_id.to_i)
  end


  def user_info
    User.find_by_id(self.user_id.to_syyy)
  end


 
end
