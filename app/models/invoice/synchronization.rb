module Invoice::Synchronization
  extend ActiveSupport::Concern

  def synchronize
    InvoiceDataSenderService.call(invoice: self)
  end
end
