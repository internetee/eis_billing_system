FactoryBot.define do
  factory :reference do
    reference_number { 123 }
    initiator { 'registry' }
    owner { 'Roga & Kopyta' }
  end
end
