export RAILS_ENV=test

for version in 3.2
do
  echo "Testing Rails version " $version
  rm Gemfile.lock
  if [ -f Gemfile.lock.$version ];
  then
    echo Reusing Gemfile.lock.$version
    cp Gemfile.lock.$version Gemfile.lock
  fi
  rm spec/test_app/db/test.sqlite3
  export RAILS_VERSION=$version
  spec/ci.sh
  cp Gemfile.lock Gemfile.lock.$version
done
