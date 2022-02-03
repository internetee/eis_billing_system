FactoryBot.define do
  factory :setting_entry do
    code { 'new_setting' }
    value { 'looks great' }
    format { 'string' }
    group { 'other' }
  end
end
