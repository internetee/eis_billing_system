class Invoice < ApplicationRecord
  enum status: %i[unpaid paid failed]
end
