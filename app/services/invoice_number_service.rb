class InvoiceNumberService
  INVOICE_NUMBER_MIN = Setting.invoice_number_min || 150_005
  INVOICE_NUMBER_MAX = Setting.invoice_number_max || 199_999
  INVOICE_NUMBER_AUCTION_DEPOSIT_MIN = Setting.invoice_number_auction_deposit_min || ENV['deposit_min_num'].to_i
  INVOICE_NUMBER_AUCTION_DEPOSIT_MAX = Setting.invoice_number_auction_deposit_max || ENV['deposit_max_num'].to_i

  def self.call(invoice_auction_deposit: false)
    if invoice_auction_deposit
      min_value = INVOICE_NUMBER_AUCTION_DEPOSIT_MIN
      max_value = INVOICE_NUMBER_AUCTION_DEPOSIT_MAX
    else
      min_value = INVOICE_NUMBER_MIN
      max_value = INVOICE_NUMBER_MAX
    end

    last_no = Invoice.all.where(invoice_number: min_value...max_value)
                     .order(invoice_number: :desc).limit(1).pick(:invoice_number)

    last_no = min_value - 1 if last_no.nil?
    number = last_no && last_no >= min_value ? last_no.to_i + 1 : min_value

    return number if number <= max_value

    'out of range'
  end
end
