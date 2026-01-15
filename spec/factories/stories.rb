FactoryBot.define do
  factory :story do
    association :user
    title { Faker::Book.title }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { "draft" }
    category { %w[Romance Fantasy Mystery Thriller SciFi Horror Adventure].sample }
    language { %w[en id ms].sample }
    view_count { 0 }

    trait :published do
      status { "published" }
    end

    trait :with_chapters do
      transient do
        chapters_count { 5 }
      end

      after(:create) do |story, evaluator|
        create_list(:chapter, evaluator.chapters_count, story: story)
      end
    end

    trait :popular do
      view_count { rand(1000..10000) }
    end
  end
end
