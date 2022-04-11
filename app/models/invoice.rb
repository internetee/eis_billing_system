class Invoice < ApplicationRecord
  include PgSearch

  pg_search_scope :search_by_number, against: [:invoice_number],
  using: {
    tsearch: {
      prefix: true
    }
  }

  enum status: %i[unpaid paid failed]

  scope :with_status, -> (status) {
    where(status: status) if status.present?
  }

  scope :with_number, -> (invoice_number) {
    search_by_number(invoice_number) if invoice_number.present?
  }

  scope :with_amount_between, -> (low, high) {
    where(transaction_amount: low.to_f..high.to_f) if low.present? && high.present?
  }

  def self.search(params={})
    sort_column = params[:sort].presence_in(%w{ invoice_number status }) || "id"
    sort_direction = params[:direction].presence_in(%w{ asc desc }) || "desc"

    self
      .with_number(params[:invoice_number].to_s.downcase)
      .with_status(params[:status])
      .with_amount_between(params[:min_amount], params[:max_amount])
      .order(sort_column => sort_direction)
  end
end
