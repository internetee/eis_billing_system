class BillingMailer < ApplicationMailer
  def inform_admin(reference_number:)
    @reference_number = reference_number
    admin_emails = User.all.collect(&:email).join(',')
    mail(to: admin_emails, subject: "#{reference_number} doesn't find")
  end
end
