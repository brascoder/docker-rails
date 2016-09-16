FROM phusion/passenger-ruby23
MAINTAINER Brasco <brasco@thebrascode.com>

ENV APP_HOME /home/app

# install dependencies
RUN apt-get update -y\
  && apt-get install -y\
    sudo

# init process
CMD ["/sbin/my_init"]
EXPOSE 80

# enable nginx
RUN rm -f /etc/service/nginx/down && rm /etc/nginx/sites-enabled/default
ADD nginx.conf /etc/nginx/sites-enabled/app.conf
ADD rails-env.conf /etc/nginx/main.d/rails-env.conf

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# bundle gems
ADD Gemfile* $APP_HOME/
WORKDIR $APP_HOME
RUN sudo -u app bundle install

# add source and precompile
ADD . $APP_HOME
RUN chown -R app:app $APP_HOME
RUN sudo -u app RAILS_ENV=production rake assets:precompile
