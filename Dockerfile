FROM --platform=linux/amd64 internetee/ruby:3.4.5-node-18-dev


RUN npm install -g yarn@latest

RUN sed -i 's/SECLEVEL=2/SECLEVEL=1/' /etc/ssl/openssl.cnf

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app

COPY Rakefile Gemfile Gemfile.lock ./

RUN bundle config set force_ruby_platform true
RUN gem install nokogiri --platform=ruby

RUN gem install bundler && bundle install --jobs 20 --retry 5
# COPY package.json yarn.lock ./
# RUN yarn install --check-files

EXPOSE 3000