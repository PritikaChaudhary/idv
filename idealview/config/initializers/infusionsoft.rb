Infusionsoft.configure do |config|
  config.api_url = ENV['INFUSIONSOFT_URL'] # example infused.infusionsoft.com
  config.api_key = ENV['INFUSIONSOFT_KEY']
  config.api_logger = Logger.new("#{Rails.root}/log/infusionsoft_api.log") # optional logger file
end