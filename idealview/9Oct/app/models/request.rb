class Request
  include MongoMapper::Document
  include ActionView::Helpers

  key :broker_id, String
  key :subbroker_id, String
  key :status, Integer
  

end
