class LoanLender
  include MongoMapper::Document
  key :copy_loan_id, String
  key :lender_id, String
  key :lender_group_id, String
  key :lender_group, Integer
  key :priority, Integer
  key :hours, Integer
  key :new_user, Integer
  key :send_date, String
  key :start_time, String
  key :end_time, String
  key :url, String
  key :saved, Integer
  key :status, String


  def copy_loan
     CopyLoan.find_by_id(self.copy_loan_id)
  end

  def lender
    Lender.find_by_id(self.lender_id)
  end

end