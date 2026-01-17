# syntax=docker/dockerfile:1
FROM ruby:3.3-alpine

WORKDIR /app
COPY . /app

RUN gem install bundler --no-document \
 && bundle install

ENTRYPOINT ["bin/chronicle"]
