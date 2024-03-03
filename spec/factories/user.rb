FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Test User #{n}" }
    email { Faker::Internet.email }
    password { 'password' }
    profile_image { 'avatar1.svg' }
    confirmed_at { Time.now }
  end
end
