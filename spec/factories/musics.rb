FactoryBot.define do
  factory :music do
    title { Faker::Lorem.words(number: 3).join(' ') }
    artist { Faker::Lorem.word }
    release_date { Faker::Date.in_date_period }
    duration { Faker::Time.between(from: DateTime.now - 1, to: DateTime.now) }
    deleted { Faker::Boolean.boolean }
  end
end