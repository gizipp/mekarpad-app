FactoryBot.define do
  factory :system_setting do
    key { "MyString" }
    value { "MyText" }
    value_type { "MyString" }
    description { "MyText" }
  end
end
