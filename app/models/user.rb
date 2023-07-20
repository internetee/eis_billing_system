class User < ApplicationRecord
  include PgSearch::Model

  has_secure_password

  validates :email, presence: true, uniqueness: true,
            format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }

  pg_search_scope :search_by_email,
                  against: [:email],
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }
end
