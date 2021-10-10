FactoryBot.define do
  factory :music do
    title { Faker::Lorem.words(number: 3).join(' ') }
    artist { Faker::Name.name }
    release_date { Faker::Date.birthday }
    duration { Faker::Time.between(from: DateTime.now - 1, to: DateTime.now) }
    number_views { Faker::Number.digit }
    feat { Faker::Boolean.boolean }
  end
end