require 'sinatra'
require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/rack'

module Admin
  module App
    class App < Sinatra::Base
      HEROKU_APPS = {
        'auth-backend' => {
          "app" => "auth-backend"
        },
        'graph-backend' => {
          "app" => "graph-backend"
        },
        'datastore-backend' => {
          "app" => "datastore-backend"
        },
        'devcenter-backend' => {
          "app" => "devcenter-backend"
        },
        'playercenter-backend' => {
          "app" => "playercenter-backend"
        },
        'canvas-app' => {
          "app" => "qs-canvas-app"
        },
        'sdk-app' => {
          "app" => "sdk-app"
        },
        'friendbarus' => {
          "app" => "friendbarus"
        }
      }

      class NewRelicMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          @app.call(env)
        end
        include NewRelic::Agent::Instrumentation::Rack
      end

      use NewRelicMiddleware

      helpers do
        def connection
          @connection ||= Connection.create
        end

        def h(text)
          Rack::Utils.escape_html(text)
        end
      end

      get '/' do
        redirect '/dashboard'
      end

      get '/dashboard' do
        @active_tab = 'dashboard'

        @metrics = {
          'players' => '???',
          'plays' => connection.tracking.query_impression('game-played', :total) + connection.tracking.query_impression('game-played-registered-player', :total),
          'signups' => {
            'today' => '???',
            'this_week' => '???'
          },
          'money_made' => {
            'today' => 0,
            'this_week' => 0
          }
        }

        erb :dashboard
      end

      get '/admin' do
        @active_tab = 'admin'

        erb :admin
      end

      post '/dynos/:app_id/:type' do
        app_id = params['app_id']
        type = params['type']
        quantity = params['quantity']
        size = params['size']

        heroku_app = HEROKU_APPS[app_id]['app']
        raise "No heroku app for #{app_id} found!" unless heroku_app

        connection.heroku.app(heroku_app).scale(type, quantity, size)

        redirect '/health'
      end

      get '/health' do
        @active_tab = 'health'

        dynos = {}

        Thread.abort_on_exception = true
        HEROKU_APPS.map do |internal_id, heroku_config|
          Thread.new do
            dynos[internal_id] = connection.heroku.app(heroku_config['app']).formation
          end
        end.each {|thread| thread.join}

        @dynos = dynos

        @charts = {
          'auth-backend' => {
            'title' => 'Auth Backend',
            '30mins' => ENV['QS_CHART_ID_AUTH_BACKEND_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_AUTH_BACKEND_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_AUTH_BACKEND_7_DAYS']
          },
          'graph-backend' => {
            'title' => 'Graph Backend',
            '30mins' => ENV['QS_CHART_ID_GRAPH_BACKEND_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_GRAPH_BACKEND_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_GRAPH_BACKEND_7_DAYS']
          },
          'datastore-backend' => {
            'title' => 'Datastore Backend',
            '30mins' => ENV['QS_CHART_ID_DATASTORE_BACKEND_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_DATASTORE_BACKEND_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_DATASTORE_BACKEND_7_DAYS']
          },
          'devcenter-backend' => {
            'title' => 'Devcenter Backend',
            '30mins' => ENV['QS_CHART_ID_DEVCENTER_BACKEND_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_DEVCENTER_BACKEND_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_DEVCENTER_BACKEND_7_DAYS']
          },
          'playercenter-backend' => {
            'title' => 'Playercenter Backend',
            '30mins' => ENV['QS_CHART_ID_PLAYERCENTER_BACKEND_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_PLAYERCENTER_BACKEND_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_PLAYERCENTER_BACKEND_7_DAYS']
          },
          'canvas-app' => {
            'title' => 'Canvas App',
            '30mins' => ENV['QS_CHART_ID_CANVAS_APP_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_CANVAS_APP_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_CANVAS_APP_7_DAYS']
          },
          'sdk-app' => {
            'title' => 'SDK App',
            '30mins' => ENV['QS_CHART_ID_SDK_APP_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_SDK_APP_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_SDK_APP_7_DAYS']
          },
          'friendbarus' => {
            'title' => 'friendbar.us',
            '30mins' => ENV['QS_CHART_ID_FRIENDBARUS_30_MINS'],
            '12hours' => ENV['QS_CHART_ID_FRIENDBARUS_12_HOURS'],
            '7days' => ENV['QS_CHART_ID_FRIENDBARUS_7_DAYS']
          }
        }

        erb :health
      end
    end
  end
end