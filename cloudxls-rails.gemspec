# -*- encoding: utf-8 -*-
$LOAD_PATH.push(File.expand_path "../lib", __FILE__)
require "cloudxls-rails/version"

Gem::Specification.new do |gem|
  gem.name          = "cloudxls-rails"
  gem.authors       = ["Sebastian Burkhard"]
  gem.email         = ["seb@cloudxls.com"]
  gem.description   = %q{Rails wrapper for the CloudXLS xpipe API}
  gem.summary       = %q{Rails wrapper for the CloudXLS xpipe API}
  gem.homepage      = "https://cloudxls.com"
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = ["lib"]
  gem.version       = CloudXLSRails::VERSION

  gem.add_dependency('cloudxls', '~> 0.6.0')

  gem.add_development_dependency "rake"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "capybara"
  gem.add_development_dependency "sqlite3"
end
