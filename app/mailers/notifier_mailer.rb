class NotifierMailer < ApplicationMailer
  def inform_admin(title:, error_message:)
    @error_message = error_message
    admin_emails = User.all.collect(&:email).join(',')
    mail(to: admin_emails, subject: title.to_s)
  end
end
