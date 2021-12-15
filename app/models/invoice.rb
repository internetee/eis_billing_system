class Invoice < ApplicationRecord
  enum status: %i[created pending failed paid]
end
