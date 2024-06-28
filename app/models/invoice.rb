class Invoice < ApplicationRecord
  include PgSearch::Model
  include Synchronization

  REGISTRY = 'registry'.freeze
  AUCTION = 'auction'.freeze
  EEID = 'eeid'.freeze
  BILLING_SYSTEM = 'billing_system'.freeze

  pg_search_scope :search_by_number, against: [:invoice_number],
                                     using: {
                                       tsearch: {
                                         prefix: true
                                       }
                                     }

  enum affiliation: { regular: 0, auction_deposit: 1, linkpay: 2 }
  enum status: { unpaid: 0, paid: 1, cancelled: 2, failed: 3, refunded: 4, overdue: 5, partially_paid: 6 }

  scope :with_status, lambda { |status|
    where(status:) if status.present?
  }

  scope :with_number, lambda { |invoice_number|
    search_by_number(invoice_number) if invoice_number.present?
  }

  scope :with_amount_between, lambda { |low, high|
    where(transaction_amount: low.to_f..high.to_f) if low.present? && high.present?
  }

  validate :payment_reference_must_change, if: :payment_reference_present_in_params?

  attr_accessor :payment_reference_in_params

  def self.search(params = {})
    sort_column = params[:sort].presence_in(%w[invoice_number status affiliation]) || 'id'
    sort_direction = params[:direction].presence_in(%w[asc desc]) || 'desc'

    with_number(params[:invoice_number].to_s.downcase)
      .with_status(params[:status])
      .with_amount_between(params[:min_amount], params[:max_amount])
      .order(sort_column => sort_direction)
  end

  def auction_deposit_prepayment?
    return false if description.nil?

    description.split(' ')[0] == 'auction_deposit'
  end

  def registry?
    initiator == REGISTRY
  end

  def eeid?
    initiator == EEID
  end

  def auction?
    initiator == AUCTION
  end

  def billing_system?
    initiator == BILLING_SYSTEM
  end

  def fully_paid?(amount)
    amount.to_f >= transaction_amount.to_f
  end

  def to_h
    {
      invoice_number:,
      initiator:,
      payment_reference:,
      transaction_amount:,
      status:,
      in_directo:,
      everypay_response:,
      transaction_time:,
      sent_at_omniva:
    }
  end

  private

  def payment_reference_present_in_params?
    payment_reference_in_params
  end

  def payment_reference_must_change
    return unless payment_reference.present? && payment_reference == payment_reference_was

    errors.add(:payment_reference, 'must be different from the existing payment reference')
  end
end
