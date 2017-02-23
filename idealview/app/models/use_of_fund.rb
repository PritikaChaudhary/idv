class UseOfFund
  include MongoMapper::Document
  key :loan_id, Integer
  key :use, String
  key :amount, Integer
  key :beneficiary, String
  key :maturityDate, String
  key :stats, String
  key :contractDate, String
  key :earnedDeposit, String
  key :is_free_related, String
  key :payid, Integer
end