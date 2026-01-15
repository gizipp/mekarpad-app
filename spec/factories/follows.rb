FactoryBot.define do
  factory :follow do
    follower { association(:user) }
    followed { association(:user) }
  end
end
