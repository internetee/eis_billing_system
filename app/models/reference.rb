class Reference < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_number, against: [:reference_number],
                                     using: {
                                       tsearch: {
                                         prefix: true,
                                       },
                                     }

  scope :with_number, lambda { |reference_number|
    search_by_number(reference_number) if reference_number.present?
  }

  def self.search(params = {})
    sort_column = params[:sort].presence_in(%w[reference_number initiator created_at]) || 'id'
    sort_direction = params[:direction].presence_in(%w[asc desc]) || 'desc'

    with_number(params[:reference_number].to_s.downcase)
      .order(sort_column => sort_direction)
  end
end
