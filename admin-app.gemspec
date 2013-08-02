# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admin/app/version'

Gem::Specification.new do |spec|
  spec.name          = "admin-app"
  spec.version       = Admin::App::VERSION
  spec.authors       = ["Thorben Schröder"]
  spec.email         = ["stillepost@gmail.com"]
  spec.description   = %q{Get an overview of what is going on in the QS tech universe and use administrative tools}
  spec.summary       = %q{Get an overview of what is going on in the QS tech universe and use administrative tools}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'auth-middleware', '>= 0.0.2'
  spec.add_dependency 'tracking-client'
  spec.add_dependency 'qs-heroku-client', '>= 0.0.2'

  spec.add_dependency 'sinatra', '~> 1.3.3'
  spec.add_dependency 'sprockets'
  spec.add_dependency 'sass'
  spec.add_dependency 'therubyracer'
  spec.add_dependency 'coffee-script'
  spec.add_dependency 'ping-middleware', '~> 0.0.2'
  spec.add_dependency 'newrelic_rpm'
  spec.add_dependency 'rack-ssl-enforcer'
end
