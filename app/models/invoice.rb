class Invoice < ApplicationRecord
  enum status: %i[created pending failed paid]

  def to_e_invoice(payable: true)
    generator = EInvoiceGenerator.new(self, payable)
    generator.generate
  end
end
