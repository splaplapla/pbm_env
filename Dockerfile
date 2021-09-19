FROM ruby:2.5

WORKDIR /pbmenv

ADD docker/Gemfile .
RUN apt-get update && apt-get install vim && gem i bundler && bundle install
