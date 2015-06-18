# robhughes.net (RHDN) web-tier Docker image source files.

## Contents
* docker-compose.yml - YAML file used by Docker Compose to simply launching development instances.

* mysql - Database configuration files.
  - mysql/database.yml - Ruby on rails database.yml template. Overwritten with database connection info when the Docker container starts the first time.`
  - mysql/mysql_env - Database connection information used in development environment.`

* nginx - Nginx configuration files to configure Nginx running inside Phusion Passenger Docker container.
  - nginx/00_app_env.conf - Set the default RAILS_ENV environment to 'production'
  - nginx/webapp.conf - Main Nginx configuration file. Sets location of Rails app, Ruby version, reverse proxy information for static content.

* scripts - Scripts to customize Docker container.
  - scripts/aa_init_db_first_time.sh - Overwrite database.yml with container specific database connection information.
  - scripts/bb_init_app_first_time.sh - RAILS app customization. Set web secret. Create web app admin user.

* insecure_key - Key used to connect to Phusion Passenger Docker container in development mode.

* Dockerfile - The Docker build configuration file.

* README.md - This readme file
