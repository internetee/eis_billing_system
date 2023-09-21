namespace :whitelist do

  # rake whitelist:add_code[60001019906]
  task :add_code, [:code] => [:environment] do |_t, args|
    WhiteCode.create!(code: args[:code])
  end
end
