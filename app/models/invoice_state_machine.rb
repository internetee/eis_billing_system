# enum status: %i[unpaid paid cancelled failed]

class InvoiceStateMachine
  attr_reader :invoice, :status

  def initialize(invoice:, status:)
    @invoice = invoice
    @status = status.to_sym
  end

  def call
    case status
    when :paid
      mark_as_paid!
    when :cancelled
      mark_as_cancel!
    when :unpaid
      mark_as_unpaid!
    else
      push_error
    end
  end

  def available_statuses
    case invoice.status
    when :paid && !invoice.payment_reference.presence
      [:paid]
    when :unpaid
      [:unpaid, :paid, :cancelled]
    when :cancelled
      [:cancelled]
    else
      [:unpaid, :paid, :cancelled]
    end
  end

  private

  def mark_as_paid!
    return push_error unless @invoice.unpaid?

    @invoice.status = :paid
    @invoice.save!
    @invoice
  end

  def mark_as_cancel!
    # Paid invoice cannot be cancelled?
    # @invoice.paid?
    return push_error unless @invoice.unpaid?

    @invoice.status = :cancelled
    @invoice.save!
    @invoice
  end

  def mark_as_unpaid!
    return push_error unless @invoice.paid? && !@invoice.payment_reference.presence

    @invoice.status = :unpaid
    @invoice.save!
    @invoice
  end

  def push_error
    @invoice.errors.add(:base, "Inavalid state #{@invoice.status}")

    @invoice
  end
end
