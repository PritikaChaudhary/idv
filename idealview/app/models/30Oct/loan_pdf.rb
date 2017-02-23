class LoanPdf
  include MongoMapper::Document
  key :pdf_id, :required=>true
  key :loan_name, String
  key :location, String
  key :amount, String
  key :summary, String
  key :sort_id, String
end