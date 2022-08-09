FactoryBot.define do
  factory :user do
    email { "admin@example.com" }
    password_digest { "MyString" }
  end
end
