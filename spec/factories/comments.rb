FactoryBot.define do
  factory :comment do
    association :user
    association :commentable, factory: :story
    content { Faker::Lorem.sentence(word_count: 15) }

    # For polymorphic associations
    trait :on_story do
      association :commentable, factory: :story
    end

    trait :on_chapter do
      association :commentable, factory: :chapter
    end

    trait :short do
      content { Faker::Lorem.sentence(word_count: 3) }
    end

    trait :long do
      content { Faker::Lorem.paragraph(sentence_count: 10) }
    end
  end
end
