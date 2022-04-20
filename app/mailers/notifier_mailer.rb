class NotifierMailer < ApplicationMailer
  def inform_admin(title:, error_message:)
    @error_message = error_message
    mail(to: 'admin', subject: "#{title}")
  end
end
