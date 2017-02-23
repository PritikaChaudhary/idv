class LoanLender
  include MongoMapper::Document
  key :copy_loan_id, String
  key :lender_id, String
  key :priority, Integer
  key :send_date, String
  key :start_time, String
  key :end_time, String
  key :status, Integer

  def copy_loan
     CopyLoan.find_by_id(self.copy_loan_id)
  end

  def lender
  	Lender.find_by_id(self.lender_id)
  end

end