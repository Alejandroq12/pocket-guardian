FactoryBot.define do
  factory :movement do
    sequence(:name) { |n| "Test Movement #{n}" }
    amount { rand(1..1000) }
    association :author, factory: :user
    association :group
  end
end
