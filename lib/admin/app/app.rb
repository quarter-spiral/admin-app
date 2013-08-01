require 'sinatra'
require 'newrelic_rpm'
require 'new_relic/agent/instrumentation/rack'

module Admin
  module App
    class App < Sinatra::Base
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
        erb :admin
      end

      get '/health' do
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