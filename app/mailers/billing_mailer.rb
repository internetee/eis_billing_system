class BillingMailer < ApplicationMailer
  def inform_admin(reference_number:, body:)
    @reference_number = reference_number
    @body = body
    admin_emails = User.all.collect(&:email).join(',')
    mail(to: admin_emails, subject: "Billing: Ref no #{reference_number} not found")
  end
end
