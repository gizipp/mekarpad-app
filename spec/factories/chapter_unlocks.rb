FactoryBot.define do
  factory :chapter_unlock do
    association :user
    association :chapter
  end
end
