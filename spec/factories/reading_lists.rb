FactoryBot.define do
  factory :reading_list do
    association :user
    association :story
  end
end
