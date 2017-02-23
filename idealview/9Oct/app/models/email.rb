class Email
  include MongoMapper::Document
  include ActionView::Helpers

  many :loans

  key :name, String
  key :subject, String
  key :content, String
  key :fixed_variable, String
  

end
