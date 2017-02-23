FogStorage = Fog::Storage.new(
  provider: "Google",
  google_storage_access_key_id:     'GOOGBBBZNVPE5AVSSDKJ',
  google_storage_secret_access_key: 'yR5ofXTe0FH9NxdYE/eA4mhrW5Ai3ZqlCik5YJJA'
)

StorageBucket = FogStorage.directories.new key: 'ideal_bucket'