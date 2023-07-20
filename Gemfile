source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 6.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'
# Use Active Model has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

gem 'rexml'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'rubocop-rails', require: false
end

group :development do
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'faker'
  gem 'selenium-webdriver'
  gem 'simplecov', '0.21.2', require: false
  gem 'webdrivers'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'database_cleaner-active_record'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# gem 'wicked_pdf' # Need to install wkhtmltopdf https://wkhtmltopdf.org/downloads.html
gem 'wkhtmltopdf-binary'
gem 'pdfkit'

gem 'money'
gem 'countries', :require => 'countries/global'

#payment features
gem 'e_invoice', github: 'internetee/e_invoice', branch: :master
gem 'directo', github: 'internetee/directo', branch: 'master'
gem 'lhv', github: 'internetee/lhv', branch: 'master'

#experimental gem
# gem 'everypay_v4_wrapper', github: 'OlegPhenomenon/everypay_v4_wrapper', branch: :master

# database handlers nd profiles
gem 'strong_migrations'

# application config file
gem 'figaro'

# deploy
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-passenger'
gem 'capistrano-rbenv'

# token feature
gem 'jwt'

# frontend
gem "hotwire-rails"
gem 'importmap-rails'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# For search
gem 'pg_search'

# Use Pagy for pagination
gem "pagy", "~> 6.0"

gem 'simpleidn', '0.2.1' # For punycode

gem 'faraday'

# specification
gem 'dry-initializer', '~> 3.1.0'
gem 'dry-validation'

gem 'net-smtp', require: false
gem 'net-imap', require: false
gem 'net-pop', require: false
gem "apipie-rails", "~> 1.1.0"

