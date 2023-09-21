FactoryBot.define do
  factory :user do
    email { "admin@example.com" }
    password_digest { "MyString" }
    uid { "EE60001019906" }
    identity_code { "60001019906" }
    provider { "tara" }
  end
end
