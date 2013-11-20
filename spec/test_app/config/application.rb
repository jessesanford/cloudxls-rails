require File.expand_path('../boot', __FILE__)

require 'rails/all'
Bundler.require

module TestApp
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = false
  end
end

