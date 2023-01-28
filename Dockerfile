FROM ruby:latest
COPY ./Gemfile /app/Gemfile
WORKDIR /app
RUN gem install bundler
RUN bundle install
EXPOSE 4567
