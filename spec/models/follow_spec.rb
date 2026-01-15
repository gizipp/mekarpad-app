require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe 'associations' do
    it { should belong_to(:follower).class_name('User') }
    it { should belong_to(:followed).class_name('User') }
  end

  describe 'validations' do
    subject { create(:follow) }

    it { should validate_uniqueness_of(:follower_id).scoped_to(:followed_id) }

    it 'prevents user from following themselves' do
      user = create(:user)
      self_follow = build(:follow, follower: user, followed: user)
      expect(self_follow).not_to be_valid
      expect(self_follow.errors[:follower]).to include('cannot follow themselves')
    end

    it 'allows user to follow another user' do
      follower = create(:user)
      followed = create(:user)
      follow = build(:follow, follower: follower, followed: followed)
      expect(follow).to be_valid
    end

    it 'prevents duplicate follow relationships' do
      follower = create(:user)
      followed = create(:user)
      create(:follow, follower: follower, followed: followed)
      duplicate = build(:follow, follower: follower, followed: followed)
      expect(duplicate).not_to be_valid
    end

    it 'allows user A to follow user B and user B to follow user A' do
      user_a = create(:user)
      user_b = create(:user)
      create(:follow, follower: user_a, followed: user_b)
      reverse = build(:follow, follower: user_b, followed: user_a)
      expect(reverse).to be_valid
    end
  end

  describe 'follow relationships' do
    let(:follower) { create(:user) }
    let(:followed) { create(:user) }
    let!(:follow) { create(:follow, follower: follower, followed: followed) }

    it 'creates correct follower relationship' do
      expect(follower.following).to include(followed)
    end

    it 'creates correct followed relationship' do
      expect(followed.followers).to include(follower)
    end

    it 'does not create reverse relationship automatically' do
      expect(followed.following).not_to include(follower)
      expect(follower.followers).not_to include(followed)
    end
  end

  describe 'cascading behavior' do
    it 'is destroyed when follower is destroyed' do
      follower = create(:user)
      create_list(:follow, 3, follower: follower)
      expect { follower.destroy }.to change { Follow.count }.by(-3)
    end

    it 'is destroyed when followed user is destroyed' do
      followed = create(:user)
      follower1 = create(:user)
      follower2 = create(:user)
      create(:follow, follower: follower1, followed: followed)
      create(:follow, follower: follower2, followed: followed)
      expect { followed.destroy }.to change { Follow.count }.by(-2)
    end

    it 'can be recreated after deletion' do
      follower = create(:user)
      followed = create(:user)
      follow = create(:follow, follower: follower, followed: followed)
      follow.destroy
      new_follow = build(:follow, follower: follower, followed: followed)
      expect(new_follow).to be_valid
    end
  end

  describe 'edge cases' do
    it 'allows a user to follow multiple users' do
      follower = create(:user)
      followed_users = create_list(:user, 5)
      followed_users.each do |followed|
        create(:follow, follower: follower, followed: followed)
      end
      expect(follower.following.count).to eq(5)
    end

    it 'allows a user to be followed by multiple users' do
      followed = create(:user)
      followers = create_list(:user, 5)
      followers.each do |follower|
        create(:follow, follower: follower, followed: followed)
      end
      expect(followed.followers.count).to eq(5)
    end

    it 'requires a follower' do
      follow = build(:follow, follower: nil)
      expect(follow).not_to be_valid
    end

    it 'requires a followed user' do
      follow = build(:follow, followed: nil)
      expect(follow).not_to be_valid
    end

    it 'maintains integrity when unfollowing' do
      follower = create(:user)
      followed = create(:user)
      follow = create(:follow, follower: follower, followed: followed)

      expect(follower.following).to include(followed)
      follow.destroy
      expect(follower.reload.following).not_to include(followed)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      follow = build(:follow)
      # Ensure follower and followed are different users
      if follow.follower_id == follow.followed_id
        follow.followed = create(:user)
      end
      expect(follow).to be_valid
    end

    it 'creates different users for follower and followed' do
      follow = create(:follow)
      expect(follow.follower).not_to eq(follow.followed)
    end

    it 'creates unique follow relationships' do
      follows = create_list(:follow, 3)
      combinations = follows.map { |f| [ f.follower_id, f.followed_id ] }
      expect(combinations.uniq.size).to eq(3)
    end
  end
end
