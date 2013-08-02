require 'tracking-client'
require 'qs/heroku/client'

module Admin::App
  class Connection
    attr_reader :tracking, :heroku

    def self.create
      new(
        ENV['QS_TRACKING_REDIS_URL'] || 'redis://localhost:6379/',
        ENV['QS_HEROKU_EMAIL'],
        ENV['QS_HEROKU_TOKEN']
      )
    end

    def initialize(tracking_backend_url, heroku_email, heroku_token)
      @tracking = ::Tracking::Client.new(tracking_backend_url)
      @heroku = ::Qs::Heroku::Client.new(heroku_email, heroku_token)
    end
  end
end
