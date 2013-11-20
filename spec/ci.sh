#!/usr/bin/env sh
cd spec/test_app && bundle install --quiet --without debug && bundle exec rake db:create  --quiet && bundle exec rake db:migrate --quiet && cd ../../ && bundle exec rspec spec
