FactoryBot.define do
  factory :bank_transaction do
    bank_reference { "MyString" }
    iban { "MyString" }
    currency { "MyString" }
    buyer_bank_code { "MyString" }
    buyer_iban { "MyString" }
    buyer_name { "MyString" }
    document_no { "MyString" }
    description { "MyString" }
    sum { 23.9 }
    reference_no { 23323 }
    paid_at { Time.zone.now }

    bank_statement { association(:bank_statement) }
  end
end
