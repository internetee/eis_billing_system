class BankTransaction < ApplicationRecord
  belongs_to :bank_statement
end
