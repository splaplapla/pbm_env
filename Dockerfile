FROM ruby:2.5

WORKDIR /pbmenv

ADD docker/Gemfile .
RUN gem i bundler && bundle install
