FactoryBot.define do
  factory :invoice do
    invoice_number { 1 }
    initiator { "registry" }
    payment_reference { nil }
    transaction_amount { "10.0" }
  end
end
