module Invoice::Synchronization
  extend ActiveSupport::Concern

  def synchronize(status:)
    InvoiceDataSenderService.call(invoice: self, status: status)
  end

  def allow_to_synchronize?
    initiator == 'registry' || initiator == 'auction'
  end
end
