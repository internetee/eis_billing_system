class Invoice < ApplicationRecord
  enum status: %i[created pending failed paid]
  belongs_to :user

  def to_e_invoice(payable: true)
    generator = EInvoiceGenerator.new(self, payable)
    generator.generate
  end

  def do_not_send_e_invoice?
    e_invoice_sent? || cancelled?
  end

  def e_invoice_sent?
    e_invoice_sent_at.present?
  end

  def cancelled?
    cancelled_at.present?
  end

  def not_cancelled?
    !cancelled?
  end

  def seller_country
    Country.new(seller_country_code)
  end

  def buyer_country
    Country.new(buyer_country_code)
  end

end
