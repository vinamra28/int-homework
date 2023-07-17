FactoryBot.define do
  factory :article do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
  end

  factory :author do
    full_name { Faker::Name.name }
    email { Faker::Internet.email(domain: 'test.anynines.com') }
  end
end
