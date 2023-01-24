FROM ruby:latest
RUN gem install sinatra
RUN gem install sinatra-contrib
RUN gem install puma
EXPOSE 4567
