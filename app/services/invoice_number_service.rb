class InvoiceNumberService
  INVOICE_NUMBER_MIN = Setting.invoice_number_min || 150_005
  INVOICE_NUMBER_MAX = Setting.invoice_number_max || 199_999

  def self.call
    last_no = Invoice.all.where(invoice_number: INVOICE_NUMBER_MIN...INVOICE_NUMBER_MAX)
                     .order(invoice_number: :desc).limit(1).pick(:invoice_number)

    number = last_no && last_no >= INVOICE_NUMBER_MIN ? last_no.to_i + 1 : INVOICE_NUMBER_MIN
    return number if number <= INVOICE_NUMBER_MAX

    'out of range'
  end
end
