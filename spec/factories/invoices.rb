FactoryBot.define do
  factory :invoice do
    description { "MyString" }
    currency { "MyString" }
    invoice_number { 2323 }
    transaction_amount { "112" }
    seller_name { "MyString" }
    seller_reg_no { "MyString" }
    seller_iban { "MyString" }
    seller_bank { "MyString" }
    seller_swift { "MyString" }
    seller_vat_no { "MyString" }
    seller_country_code { "MyString" }
    seller_state { "MyString" }
    seller_street { "MyString" }
    seller_city { "MyString" }
    seller_zip { "MyString" }
    seller_phone { "MyString" }
    seller_url { "MyString" }
    seller_email { "MyString" }
    seller_contact_name { "MyString" }
    buyer_name { "MyString" }
    buyer_reg_no { "MyString" }
    buyer_country_code { "MyString" }
    buyer_state { "MyString" }
    buyer_street { "MyString" }
    buyer_city { "MyString" }
    buyer_zip { "MyString" }
    buyer_phone { "MyString" }
    buyer_url { "MyString" }
    buyer_email { "MyString" }
    vat_rate { "MyString" }
    reference_number { "MyString" }

    invoice_items {[{ description: 'prepayment',
                      price: 123,
                      quantity: 2,
                      unit: 'piece' },
                    { description: 'prepayment',
                      price: 13,
                      quantity: 1,
                      unit: 'piece' } ]}

    user { association(:user) }
  end
end
