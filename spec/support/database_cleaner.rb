RSpec.configure do |config|

  # config.before(:suite) do
  #   # DatabaseCleaner.clean_with(:truncation)
  #   if config.use_transactional_fixtures?
	# 		# raise(<<-MSG)      
	# 		# 	Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
	# 		# 	(or set it to false) to prevent uncommitted transactions being used in
	# 		# 	JavaScript-dependent specs.
	# 		# 	During testing, the app-under-test that the browser driver connects to
	# 		# 	uses a different database connection to the database connection used by
	# 		# 	the spec. The app's database connection would not be able to access
	# 		# 	uncommitted transaction data setup over the spec's database connection.        
	# 		# MSG
	# 	end
	# 	DatabaseCleaner.clean_with(:truncation)
  # end

  # config.before(:each) do
  #   DatabaseCleaner.strategy = :transaction
  # end

  # config.before(:each, :js => true) do
  #   DatabaseCleaner.strategy = :truncation
  # end

  # config.before(:each) do
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
end
