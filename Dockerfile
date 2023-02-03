FROM ruby:3.0

WORKDIR /pbmenv

ENV CI=1
ADD docker/Gemfile .
RUN apt-get update && apt-get install vim -y && gem i bundler && bundle install
