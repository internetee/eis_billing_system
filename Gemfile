source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.3'
gem 'pg', '~> 1.1'
gem 'puma', '~> 6.4.0'
gem 'redis', '~> 5.0'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'rexml'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'wkhtmltopdf-binary'
gem 'pdfkit'
gem 'money'
gem 'countries', :require => 'countries/global'
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'directo', github: 'internetee/directo', branch: :master
gem 'lhv', github: 'internetee/lhv', branch: 'master'
gem 'strong_migrations'
gem 'figaro'
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-passenger'
gem 'capistrano-rbenv'
gem 'jwt'
gem "hotwire-rails"
gem 'importmap-rails'
gem 'sprockets-rails'
gem 'pg_search'
gem "pagy", "~> 7.0"
gem 'simpleidn', '0.2.1'
gem 'faraday'
gem 'dry-initializer', '~> 3.1.0'
gem 'dry-validation'
gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem "apipie-rails", "~> 1.3.0"
gem 'omniauth', '>=2.0.0'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-tara', github: 'internetee/omniauth-tara'
gem 'i18n-tasks', '~> 1.0.12'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rubocop-rails', require: false
  gem 'bundle-audit', require: false
  gem 'brakeman', require: false
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'faker'
  gem 'selenium-webdriver'
  gem 'simplecov', '0.21.2', require: false
  gem 'webdrivers'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'database_cleaner-active_record'
end
