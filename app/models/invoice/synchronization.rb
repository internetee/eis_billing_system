module Invoice::Synchronization
  extend ActiveSupport::Concern

  def synchronize(status)
    InvoiceDataSenderService.call(invoice: self, status: status)
  end
end
