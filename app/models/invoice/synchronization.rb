module Invoice::Synchronization
  extend ActiveSupport::Concern

  def synchronize(status:)
    return error_structure if restricted_statuses.include?(status) || !allow_to_synchronize?

    InvoiceDataSenderService.call(invoice: self, status:)
  end

  def allow_to_synchronize?
    initiator == 'registry' || initiator == 'auction'
  end

  def restricted_statuses
    ['overdue']
  end

  def error_structure
    Struct.new(:result?, :instance, :errors).new(false, nil, 'You can not change to this status!')
  end
end
