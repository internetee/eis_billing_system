class User < ApplicationRecord
  include PgSearch::Model
  include Authentication

  has_secure_password :password, validations: false

  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }, allow_nil: true
  has_many :app_sessions, dependent: :destroy

  pg_search_scope :search_by_email,
                  against: [:email],
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  }

  def self.from_omniauth(omniauth_hash)
    uid = omniauth_hash['uid']
    provider = omniauth_hash['provider']

    user = User.find_or_initialize_by(identity_code: uid.slice(2..-1))
    user.provider = provider
    user.uid = uid
    user.identity_code = uid.slice(2..-1)

    user
  end
end
