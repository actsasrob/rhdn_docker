#!/bin/bash

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

# bundle gems
#bundle install || error_exit 'Failed to hundle install'

# run 'rake secret' and add secret key to config/secret.yml
NEW_SECRET=$(rake secret)
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
RAILS_ENV=$PASSENGER_APP_ENV rake --trace db:migrate || error_exit 'Failed to rake db:migrate'

# Create the app admin user

#echo "RAILS_ENV=$PASSENGER_APP_ENV rails runner User.create({ :name => "$APP_ADMIN_USERNAME", :password => "$APP_ADMIN_PASSWORD", :password_confirmation => "$APP_ADMIN_PASSWORD" }).save"

#RAILS_ENV=$PASSENGER_APP_ENV rails runner User.create({ :name => "$APP_ADMIN_USERNAME", :password => "$APP_ADMIN_PASSWORD", :password_confirmation => "$APP_ADMIN_PASSWORD" }).save

echo "HOME=/home/app bundle exec rails runner -e $PASSENGER_APP_ENV  \"User.create({ :name => '$APP_ADMIN_USERNAME', :password => '$APP_ADMIN_PASSWORD', :password_confirmation => '$APP_ADMIN_PASSWORD' }).save\""

HOME=/home/app bundle exec rails runner -e $PASSENGER_APP_ENV  "User.create({ :name => '$APP_ADMIN_USERNAME', :password => '$APP_ADMIN_PASSWORD', :password_confirmation => '$APP_ADMIN_PASSWORD' }).save"

exit 0