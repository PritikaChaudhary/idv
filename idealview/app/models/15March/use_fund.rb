class UseFund
  include MongoMapper::Document
  key :copy_loan_id, :required=>true
  key :fund_id, String
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