class DropboxToken
  include MongoMapper::Document
  key :user_id, String
  key :token, String
  key :not_sync, Integer
end