FROM internetee/ruby:3.2.2-bullseye


RUN npm install -g yarn@latest

RUN sed -i 's/SECLEVEL=2/SECLEVEL=1/' /etc/ssl/openssl.cnf

RUN mkdir -p /opt/webapps/app/tmp/pids
WORKDIR /opt/webapps/app

COPY Rakefile Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
# COPY package.json yarn.lock ./
# RUN yarn install --check-files

EXPOSE 3000