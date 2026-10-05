# The app pins ruby 3.4.10 (.ruby-version + Gemfile), for which there is no
# internetee/ruby image, so the official image is used directly. The app only
# needs ruby + libpq: assets are served through importmap, no node build step.
FROM ruby:3.4.10-bookworm

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends libpq-dev postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/SECLEVEL=2/SECLEVEL=1/' /etc/ssl/openssl.cnf

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app

COPY Rakefile Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform true
RUN gem install bundler && bundle install --jobs 20 --retry 5
# COPY package.json yarn.lock ./
# RUN yarn install --check-files

EXPOSE 3000