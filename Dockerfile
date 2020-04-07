FROM ruby:2.6

MAINTAINER Yoshikazu Aoyama <yskz.aoyama@gmail.com>

ARG timezone="Asia/Tokyo"
ENV TZ=$timezone
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /toggl_report
WORKDIR /toggl_report
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD report.rb report.rb
ADD toggl_report.rb toggl_report.rb
RUN gem install bundler
RUN bundle config set path vendor
RUN bundle install
CMD bundle exec ruby toggl_report.rb
