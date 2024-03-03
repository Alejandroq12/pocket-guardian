FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Test Group #{n}" }
    icon { Group.icon_choices.sample }
    association :user
  end
end
