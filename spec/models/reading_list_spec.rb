require 'rails_helper'

RSpec.describe ReadingList, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:story) }
  end

  describe 'validations' do
    subject { create(:reading_list) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:story_id) }

    it 'allows user to add different stories to reading list' do
      user = create(:user)
      story1 = create(:story)
      story2 = create(:story)
      create(:reading_list, user: user, story: story1)
      reading_list2 = build(:reading_list, user: user, story: story2)
      expect(reading_list2).to be_valid
    end

    it 'allows different users to add same story to their reading lists' do
      story = create(:story)
      user1 = create(:user)
      user2 = create(:user)
      create(:reading_list, user: user1, story: story)
      reading_list2 = build(:reading_list, user: user2, story: story)
      expect(reading_list2).to be_valid
    end

    it 'prevents duplicate entries of same story in user reading list' do
      user = create(:user)
      story = create(:story)
      create(:reading_list, user: user, story: story)
      duplicate = build(:reading_list, user: user, story: story)
      expect(duplicate).not_to be_valid
    end
  end

  describe 'user saved stories relationship' do
    let(:user) { create(:user) }
    let(:story) { create(:story) }
    let!(:reading_list) { create(:reading_list, user: user, story: story) }

    it 'adds story to user saved stories' do
      expect(user.saved_stories).to include(story)
    end

    it 'can retrieve all saved stories for a user' do
      stories = create_list(:story, 3)
      stories.each { |s| create(:reading_list, user: user, story: s) }
      expect(user.saved_stories.count).to eq(4) # 3 + 1 from let!
    end
  end

  describe 'cascading behavior' do
    it 'is destroyed when user is destroyed' do
      user = create(:user)
      create_list(:reading_list, 3, user: user)
      expect { user.destroy }.to change { ReadingList.count }.by(-3)
    end

    it 'is destroyed when story is destroyed' do
      story = create(:story)
      create_list(:reading_list, 3, story: story)
      expect { story.destroy }.to change { ReadingList.count }.by(-3)
    end

    it 'can be recreated after deletion' do
      user = create(:user)
      story = create(:story)
      reading_list = create(:reading_list, user: user, story: story)
      reading_list.destroy
      new_reading_list = build(:reading_list, user: user, story: story)
      expect(new_reading_list).to be_valid
    end
  end

  describe 'edge cases' do
    it 'allows a user to have many stories in reading list' do
      user = create(:user)
      stories = create_list(:story, 10)
      stories.each { |story| create(:reading_list, user: user, story: story) }
      expect(user.saved_stories.count).to eq(10)
    end

    it 'allows a story to be in many users reading lists' do
      story = create(:story)
      users = create_list(:user, 10)
      users.each { |user| create(:reading_list, user: user, story: story) }
      expect(story.reading_lists.count).to eq(10)
    end

    it 'requires a user association' do
      reading_list = build(:reading_list, user: nil)
      expect(reading_list).not_to be_valid
    end

    it 'requires a story association' do
      reading_list = build(:reading_list, story: nil)
      expect(reading_list).not_to be_valid
    end

    it 'works with draft and published stories' do
      user = create(:user)
      draft_story = create(:story, status: 'draft')
      published_story = create(:story, :published)

      draft_list = build(:reading_list, user: user, story: draft_story)
      published_list = build(:reading_list, user: user, story: published_story)

      expect(draft_list).to be_valid
      expect(published_list).to be_valid
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:reading_list)).to be_valid
    end

    it 'creates unique user-story combinations' do
      reading_lists = create_list(:reading_list, 3)
      combinations = reading_lists.map { |rl| [ rl.user_id, rl.story_id ] }
      expect(combinations.uniq.size).to eq(3)
    end
  end
end
