require 'tracking-client'

module Admin::App
  class Connection
    attr_reader :tracking

    def self.create
      new(
        ENV['QS_TRACKING_REDIS_URL'] || 'redis://localhost:6379/'
      )
    end

    def initialize(tracking_backend_url)
      @tracking = ::Tracking::Client.new(tracking_backend_url)
    end
  end
end
