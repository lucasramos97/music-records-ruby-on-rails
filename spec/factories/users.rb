FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:email) { |n| "user#{n}@email.com" }
    password { '123' }
  end
end