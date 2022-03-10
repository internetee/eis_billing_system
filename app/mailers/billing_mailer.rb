class BillingMailer < ApplicationMailer
  def inform_admin(reference_number:)
    @reference_number = reference_number
    mail(to: 'admin', subject: "#{reference_number} doesn't find")
  end
end
