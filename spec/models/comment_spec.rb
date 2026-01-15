require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_least(1).is_at_most(1000) }

    context 'content length validation' do
      it 'accepts content with 1 character' do
        comment = build(:comment, content: 'A')
        expect(comment).to be_valid
      end

      it 'accepts content with 1000 characters' do
        comment = build(:comment, content: 'a' * 1000)
        expect(comment).to be_valid
      end

      it 'rejects content with 0 characters' do
        comment = build(:comment, content: '')
        expect(comment).not_to be_valid
      end

      it 'rejects content with more than 1000 characters' do
        comment = build(:comment, content: 'a' * 1001)
        expect(comment).not_to be_valid
      end

      it 'rejects nil content' do
        comment = build(:comment, content: nil)
        expect(comment).not_to be_valid
      end
    end
  end

  describe 'polymorphic associations' do
    context 'when commentable is a Story' do
      let(:story) { create(:story) }
      let(:comment) { create(:comment, :on_story, commentable: story) }

      it 'can be associated with a story' do
        expect(comment.commentable_type).to eq('Story')
        expect(comment.commentable).to eq(story)
      end

      it 'is included in story comments' do
        expect(story.comments).to include(comment)
      end
    end

    context 'when commentable is a Chapter' do
      let(:chapter) { create(:chapter) }
      let(:comment) { create(:comment, :on_chapter, commentable: chapter) }

      it 'can be associated with a chapter' do
        expect(comment.commentable_type).to eq('Chapter')
        expect(comment.commentable).to eq(chapter)
      end

      it 'is included in chapter comments' do
        expect(chapter.comments).to include(comment)
      end
    end
  end

  describe 'scopes' do
    describe '.recent' do
      let!(:old_comment) { create(:comment, :on_story, created_at: 2.days.ago) }
      let!(:recent_comment) { create(:comment, :on_story, created_at: 1.hour.ago) }
      let!(:newest_comment) { create(:comment, :on_story, created_at: 5.minutes.ago) }

      it 'orders comments by creation date descending' do
        comments = Comment.recent
        expect(comments.first).to eq(newest_comment)
        expect(comments.last).to eq(old_comment)
      end

      it 'returns all comments in reverse chronological order' do
        expect(Comment.recent.to_a).to eq([ newest_comment, recent_comment, old_comment ])
      end
    end
  end

  describe 'edge cases' do
    it 'allows same user to comment multiple times on same story' do
      user = create(:user)
      story = create(:story)
      create(:comment, user: user, commentable: story)
      second_comment = build(:comment, user: user, commentable: story)
      expect(second_comment).to be_valid
    end

    it 'allows same user to comment on multiple stories' do
      user = create(:user)
      story1 = create(:story)
      story2 = create(:story)
      create(:comment, user: user, commentable: story1)
      comment2 = build(:comment, user: user, commentable: story2)
      expect(comment2).to be_valid
    end

    it 'allows multiple users to comment on same story' do
      story = create(:story)
      user1 = create(:user)
      user2 = create(:user)
      create(:comment, user: user1, commentable: story)
      comment2 = build(:comment, user: user2, commentable: story)
      expect(comment2).to be_valid
    end

    it 'requires a user association' do
      comment = build(:comment, :on_story, user: nil)
      expect(comment).not_to be_valid
    end

    it 'requires a commentable association' do
      comment = build(:comment, commentable: nil)
      expect(comment).not_to be_valid
    end

    it 'is destroyed when user is destroyed' do
      user = create(:user)
      create_list(:comment, 3, :on_story, user: user)
      expect { user.destroy }.to change { Comment.count }.by(-3)
    end

    it 'is destroyed when story is destroyed' do
      story = create(:story)
      create_list(:comment, 3, commentable: story)
      expect { story.destroy }.to change { Comment.count }.by(-3)
    end

    it 'is destroyed when chapter is destroyed' do
      chapter = create(:chapter)
      create_list(:comment, 3, commentable: chapter)
      expect { chapter.destroy }.to change { Comment.count }.by(-3)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:comment, :on_story)).to be_valid
    end

    it 'has a valid on_story trait' do
      comment = create(:comment, :on_story)
      expect(comment.commentable_type).to eq('Story')
    end

    it 'has a valid on_chapter trait' do
      comment = create(:comment, :on_chapter)
      expect(comment.commentable_type).to eq('Chapter')
    end

    it 'has a valid short trait' do
      comment = build(:comment, :short, :on_story)
      expect(comment.content.length).to be <= 50
    end

    it 'has a valid long trait' do
      comment = build(:comment, :long, :on_story)
      expect(comment.content.length).to be > 100
    end
  end
end
