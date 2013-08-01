require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

task :default => :test

require 'sinatra/asset_pipeline/task.rb'
require 'admin/app'

Sinatra::AssetPipeline::Task.define! Admin::App::App