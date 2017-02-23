class MarketAccess
  include MongoMapper::Document
  key :market_id, Integer
  key :lender_id, String
  key :loan_id, String
  key :user_id, String
  # one :loan, :in => :loan_id

end