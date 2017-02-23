require File.expand_path('../boot', __FILE__)


# Pick the frameworks you want:
require "active_model/railtie"
#require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
# require 'pdfkit'
  
# config.middleware.use PDFKit::Middleware
#config.threadsafe!


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

ENV['INFUSIONSOFT_URL'] = "tb173.infusionsoft.com"
ENV['INFUSIONSOFT_KEY'] = "f65f9f22eb0af1fb5544f6ced683aeaf"
ENV['RECURLY_SUBDOMAIN']= "idealview"
ENV['RECURLY_API_KEY'] = "f20bfe7c234c4b17bd5bf009315be5c7"
ENV['RECURLY_PUBLIC_API_KEY'] = "ewr1-Si1772BTvzpk8Qer5H6Oys"
# protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }
Bundler.require(*Rails.groups)

module FundingDatabase
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # config.assets.image_optim = false
     # config.paperclip_defaults = { :compression => { :png => '-optimize', :jpeg => '-optimize' } }
    # ...
    # protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }
    config.generators do |g|
      g.orm :mongo_mapper

      g.test_framework :rspec, 
        :fixtures => true, 
        :view_specs => false, 
        :helper_specs => false, 
        :routing_specs => false, 
        :controller_specs => true, 
        :request_specs => true 
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      
    end

    
  end
end




