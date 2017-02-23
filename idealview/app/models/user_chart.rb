class UserChart
  include MongoMapper::Document
  key :user_id, String
  key :search_type, String
  key :from_date, String
  key :to_date, String
  key :chart_type, String
  key :chart_type_loan, String
  key :chart_type_amount, String
  key :lending_types, String
  key :transaction_type, String
  key :states, String
  key :min_amnt, String
  key :max_amnt, String
  key :min_estimated_val, String
  key :max_estimated_val, String
end