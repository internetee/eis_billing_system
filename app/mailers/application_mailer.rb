class ApplicationMailer < ActionMailer::Base
  default from: ENV['action_mailer_default_from']
  layout 'mailer'
end
