class WhiteCode < ApplicationRecord
  validates :code, presence: true, length: { minimum: 10, maximum: 12 }
end
