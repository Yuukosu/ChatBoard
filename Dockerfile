FROM ruby:latest
RUN gem install sinatra
RUN gem install sinatra-contrib
RUN gem install puma
RUN gem install activerecord
RUN gem install sinatra-activerecord
EXPOSE 4567
