# === 1 === 
FROM phusion/passenger-ruby21:latest 

# Credit and Thanks to Jeroen van Baarsen at
# See more at: https://intercityup.com/blog/how-i-build-a-docker-image-for-my-rails-app.html#sthash.k9Xm87VI.dpuf
MAINTAINER Robert Hughes "acts.as.rob@gmail.com" 

# Set correct environment variables. 
ENV HOME /root 

# Use baseimage-docker's init system. 
CMD ["/sbin/my_init"] 

# === 2 === # Start Nginx / Passenger 
RUN rm -f /etc/service/nginx/down 

# === 3 ==== # Remove the default site 
RUN rm /etc/nginx/sites-enabled/default 

# Add the nginx info 
ADD nginx/webapp.conf /etc/nginx/sites-enabled/webapp.conf 
ADD nginx/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

# === 4 === # Prepare folders 
#RUN mkdir /home/app/webapp 

# === 5 === # Run Bundle in a cache efficient way 
WORKDIR /tmp 

RUN apt-get update && apt-get install -y curl
#ADD https://gitlab.com/robhughesdotnet/rhdn_ror/repository/archive.tar.gz /home/app/webapp/
RUN mkdir -p /home/app \
    && curl -SL https://gitlab.com/robhughesdotnet/rhdn_ror/repository/archive.tar.gz \
    |  tar -xz -C /home/app/ && mv /home/app/rhdn_ror.git /home/app/webapp

RUN ls -al /home/app/webapp/

#ADD rhdn_ror/Gemfile /tmp/ 
#ADD rhdn_ror/Gemfile.lock /tmp/ 
RUN cd /home/app/webapp && bundle install
#RUN bundle install 

# === 6 === # Add the rails app 
#ADD rhdn_ror /home/app/webapp 

ADD mysql/database.yml /home/app/webapp/config/

RUN chown -R app:app /home/app/webapp

# Add database and app startup scripts
RUN mkdir -p /etc/my_init.d
ADD scripts/* /etc/my_init.d/

# Clean up APT when done. 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
