class User < ApplicationRecord
  enum role: %i[private_user org_user registrar]

  has_many :invoices
end
