FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    bio { Faker::Lorem.paragraph }

    trait :with_otp do
      otp_code { rand(100000..999999).to_s }
      otp_sent_at { Time.current }
    end

    trait :with_expired_otp do
      otp_code { rand(100000..999999).to_s }
      otp_sent_at { 20.minutes.ago }
    end

    trait :with_stories do
      transient do
        stories_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:story, evaluator.stories_count, user: user)
      end
    end

    trait :with_followers do
      transient do
        followers_count { 5 }
      end

      after(:create) do |user, evaluator|
        evaluator.followers_count.times do
          follower = create(:user)
          create(:follow, follower: follower, followed: user)
        end
      end
    end
  end
end
