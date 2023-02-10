FactoryBot.define do
  factory :invoice do
    invoice_number { 1 }
    initiator { 'registry' }
    payment_reference { 'db98561ec7a380d2e0872a34ffccdd0c4d2f2fd237b6d0ac22f88f52a' }
    transaction_amount { '10.0' }
  end
end
