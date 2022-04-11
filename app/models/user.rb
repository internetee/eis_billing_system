class User < ApplicationRecord
  include PgSearch

  # adds virtual attributes for authentication
  has_secure_password
  # validates email
  validates :email, presence: true, uniqueness: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }

  pg_search_scope :search_by_email, against: [:email],
  using: {
    tsearch: {
      prefix: true
      # negation: true,
      # highlight: {
      #   start_sel: '<span class="text-indigo-600">',
      #   stop_sel: '</span>',
      # }
    }
  }
end
