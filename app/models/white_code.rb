class WhiteCode < ApplicationRecord
  validates :code, presence: true, uniqueness: true, length: { is: 11 }
end
