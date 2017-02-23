class Role
  include MongoMapper::EmbeddedDocument
  key :name, String
  embedded_in :user
end

