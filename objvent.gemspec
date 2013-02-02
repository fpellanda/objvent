require File.expand_path('../lib/objvent/rails/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "objvent"
  s.version = Objvent::Rails::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Flavio Pellanda"]
  s.email = ["flavio@apache.org"]
  s.homepage = "http://github.com/fpellanda/objvent"
  s.summary = "Share events on JS and ruby objects and across rails, browser and backend servers"
  s.description = "Keep your objectspace synchronized in ruby, rails and javascript with hightspeed. And the best, you can trigger events on objects and listen to them on server and client side!"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "objvent"

  s.add_dependency "redis-objects"
  s.add_dependency "em-hiredis"
  s.add_dependency "activesupport"
  s.add_dependency "websocket-rails"
  s.add_dependency "uuid"
  s.add_dependency "state_machine"

  s.add_development_dependency "bundler"
  
  s.require_path = 'lib'
end