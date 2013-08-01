Bundler.require

require 'admin/app'
require 'auth/middleware'
require 'sprockets'
require 'ping-middleware'
require 'rack/ssl-enforcer'

app = Rack::Builder.new do
  use Ping::Middleware
  use Rack::SslEnforcer if ENV['RACK_ENV'].downcase == 'production'

  use Rack::Session::Cookie, key: 'qs_admin_backend_session', secret: ENV['QS_COOKIE_SECRET'] || 'super-secret'
  use Auth::Middleware, ENV['QS_OAUTH_CLIENT_ID'], ENV['QS_OAUTH_CLIENT_SECRET'], 'qs_admin_backend_auth' do |auth_tools|
    auth_tools.require_admin!
  end

  map "/assets" do
    environment = Sprockets::Environment.new
    environment.append_path File.expand_path("../lib/admin/app/assets", __FILE__)
    run environment
  end

  run Admin::App::App
end

run app