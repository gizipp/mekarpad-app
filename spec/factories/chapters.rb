FactoryBot.define do
  factory :chapter do
    association :story
    sequence(:title) { |n| "Chapter #{n}: #{Faker::Book.title}" }
    content { Faker::Lorem.paragraphs(number: 10).join("\n\n") }
    sequence(:order)
    status { 'draft' }

    trait :draft do
      status { 'draft' }
    end

    trait :published do
      status { 'published' }
    end

    trait :with_comments do
      transient do
        comments_count { 3 }
      end

      after(:create) do |chapter, evaluator|
        create_list(:comment, evaluator.comments_count, commentable: chapter)
      end
    end

    trait :first_chapter do
      order { 1 }
    end

    trait :last_chapter do
      order { 999 }
    end
  end
end
