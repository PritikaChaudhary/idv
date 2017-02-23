class Nda
  include MongoMapper::Document
  key :loan_id, :required=>true
  key :email, :required=>true
  key :name, :required=>true
  key :date, :required=>true
  belongs_to :loan

end