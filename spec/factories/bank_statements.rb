FactoryBot.define do
  factory :bank_statement do
    bank_code { "MyString" }
    iban { "MyString" }
    queried_at { Time.zone.now }
  end
end
