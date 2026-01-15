require 'rails_helper'

RSpec.describe ChapterUnlock, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:chapter) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:chapter) { create(:chapter) }
    let!(:existing_unlock) { create(:chapter_unlock, user: user, chapter: chapter) }

    it 'validates uniqueness of user_id scoped to chapter_id' do
      duplicate_unlock = build(:chapter_unlock, user: user, chapter: chapter)
      expect(duplicate_unlock).not_to be_valid
    end

    it 'allows same user to unlock different chapters' do
      other_chapter = create(:chapter)
      unlock = build(:chapter_unlock, user: user, chapter: other_chapter)
      expect(unlock).to be_valid
    end

    it 'allows different users to unlock same chapter' do
      other_user = create(:user)
      unlock = build(:chapter_unlock, user: other_user, chapter: chapter)
      expect(unlock).to be_valid
    end
  end

  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:chapter) { create(:chapter) }

    it 'has unique index on user_id and chapter_id' do
      create(:chapter_unlock, user: user, chapter: chapter)
      duplicate = build(:chapter_unlock, user: user, chapter: chapter)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:chapter_unlock)).to be_valid
    end

    it 'creates unlock record successfully' do
      expect { create(:chapter_unlock) }.to change { ChapterUnlock.count }.by(1)
    end
  end
end
