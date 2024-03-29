ENV["RAILS_ENV"] = 'test'
require File.expand_path("../test_app/config/environment", __FILE__)
require 'bundler'
require 'bundler/setup'
require 'rspec/rails'
require 'capybara/rspec'

# Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.color_enabled = true
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
end

module ::RSpec::Core
  class ExampleGroup
    include Capybara::DSL
    include Capybara::RSpecMatchers
  end
end
