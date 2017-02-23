S3 = Aws::S3::Client.new(region: 'us-west-2',
          access_key_id: 'AKIAJ62MUN64UV7HLZSA',
          secret_access_key: '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'
)

if ENV['RAILS_ENV'] == 'production'
  S3_BUCKET_NAME = 'idealview'
else
  S3_BUCKET_NAME = 'idealview'
end  
