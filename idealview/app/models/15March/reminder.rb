class Reminder
  include MongoMapper::Document
  key :num, Integer
  key :units, String
  key :copy_loan_id, String
  key :status, Integer

  def copy_loan
     CopyLoan.find_by_id(self.copy_loan_id)
  end
end