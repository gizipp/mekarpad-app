FactoryBot.define do
  factory :reading_progress do
    association :user
    association :story
    association :chapter

    trait :without_chapter do
      chapter { nil }
    end
  end
end
