#!/bin/bash

set -x

# Helper function
function error_exit
{
  echo "$1"
  logger -t $0 "$1"
  exit 1
}

whoami

WRK_DIR=/home/app/webapp

cd $WRK_DIR || error_exit 'Failed to cd to rhdn project'
pwd

# bundle gems
#bundle install || error_exit 'Failed to hundle install'
#bundle update io-console || error_exit 'Failed to hundle install'

bundle list
gem list
#Grrr.... the phusion/passenger-ruby21:latest Docker image contains a version of io-console that is activated which overrides the version of io-console in the Gemfile.lock file. It also strangely
#uses a version of the gem that is not available in rubygems.org which prevents the Rails app from specifying that same version. So let's get rid of this version of the gem. 
find  /usr/lib/ruby/gems/2.1.0/specifications -name "io-console-*.gemspec" -exec rm -f {} \;
gem list
#cat /home/app/webapp/Gemfile*
find / -name "io-console*"

# run 'rake secret' and add secret key to config/secret.yml
NEW_SECRET=$(bundle exec rake secret)
if [ -z "$NEW_SECRET" ]; then
   error_exit 'Failed to generate new secret'
fi
sed -i -e "s/CHANGE_ME/$NEW_SECRET/" $WRK_DIR/config/secrets.yml

echo "/etc/nginx/sites-enabled/webapp.conf:"
cat /etc/nginx/sites-enabled/webapp.conf

# Wait for database to start up
sleep 5

# Make sure any outstanding DB migrations have been applied
echo "PASSENGER_APP_ENV=$PASSENGER_APP_ENV"
RAILS_ENV=$PASSENGER_APP_ENV bundle exec rake --trace db:migrate || error_exit 'Failed to rake db:migrate'

# Create the app admin user
#echo "HOME=/home/app bundle exec rails runner -e $PASSENGER_APP_ENV  \"User.create({ :name => '$APP_ADMIN_USERNAME', :password => '$APP_ADMIN_PASSWORD', :password_confirmation => '$APP_ADMIN_PASSWORD' }).save\""

HOME=/home/app bundle exec rails runner -e $PASSENGER_APP_ENV  "User.create({ :name => '$APP_ADMIN_USERNAME', :password => '$APP_ADMIN_PASSWORD', :password_confirmation => '$APP_ADMIN_PASSWORD' }).save"

exit 0
