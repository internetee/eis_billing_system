FROM internetee/ruby:3.0-buster
ARG RAILS_ENV
ARG SECRET_KEY_BASE
ARG APP_DBHOST
ARG POSTGRES_PASSWORD

ENV RAILS_ENV "$RAILS_ENV"
ENV SECRET_KEY_BASE "$SECRET_KEY_BASE"
ENV APP_DBHOST "$APP_DBHOST"
RUN npm install -g yarn@latest
WORKDIR /opt/webapps/app
RUN mkdir -p /opt/webapps/app/tmp/pids
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

# RUN gem install bundler && bundle update --bundler && bundle update && bundle install

COPY . .
EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
