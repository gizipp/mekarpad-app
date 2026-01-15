require 'rails_helper'

RSpec.describe Story, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:chapters).dependent(:destroy) }
    it { should have_one_attached(:cover_image) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:category) }
    it { should validate_presence_of(:language) }
    it { should validate_length_of(:title).is_at_least(1).is_at_most(200) }
    it { should validate_inclusion_of(:status).in_array(%w[draft published]) }
    it { should validate_inclusion_of(:language).in_array(%w[en id ms]) }

    context 'title length validation' do
      it 'accepts title with 1 character' do
        story = build(:story, title: 'A')
        expect(story).to be_valid
      end

      it 'accepts title with 200 characters' do
        story = build(:story, title: 'a' * 200)
        expect(story).to be_valid
      end

      it 'rejects title with 0 characters' do
        story = build(:story, title: '')
        expect(story).not_to be_valid
      end

      it 'rejects title with more than 200 characters' do
        story = build(:story, title: 'a' * 201)
        expect(story).not_to be_valid
      end
    end

    context 'status validation' do
      it 'accepts draft status' do
        story = build(:story, status: 'draft')
        expect(story).to be_valid
      end

      it 'accepts published status' do
        story = build(:story, status: 'published')
        expect(story).to be_valid
      end

      it 'rejects invalid status' do
        story = build(:story, status: 'archived')
        expect(story).not_to be_valid
      end

      it 'rejects nil status' do
        story = build(:story, status: nil)
        expect(story).not_to be_valid
      end
    end

    context 'language validation' do
      it 'accepts English (en)' do
        story = build(:story, language: 'en')
        expect(story).to be_valid
      end

      it 'accepts Indonesian (id)' do
        story = build(:story, language: 'id')
        expect(story).to be_valid
      end

      it 'accepts Malay (ms)' do
        story = build(:story, language: 'ms')
        expect(story).to be_valid
      end

      it 'rejects invalid language' do
        story = build(:story, language: 'fr')
        expect(story).not_to be_valid
      end

      it 'rejects nil language' do
        story = build(:story, language: nil)
        expect(story).not_to be_valid
      end
    end

    context 'category validation' do
      it 'accepts valid category' do
        story = build(:story, category: 'Romance')
        expect(story).to be_valid
      end

      it 'requires category to be present' do
        story = build(:story, category: nil)
        expect(story).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:draft_story) { create(:story, status: 'draft') }
    let!(:published_story) { create(:story, status: 'published') }
    let!(:romance_story) { create(:story, status: 'published', category: 'Romance') }
    let!(:fantasy_story) { create(:story, status: 'published', category: 'Fantasy') }
    let!(:english_story) { create(:story, status: 'published', language: 'en') }
    let!(:indonesian_story) { create(:story, status: 'published', language: 'id') }
    let!(:popular_story) { create(:story, :popular, status: 'published') }
    let!(:recent_story) { create(:story, status: 'published') }
    let!(:old_story) { create(:story, status: 'published', created_at: 1.month.ago) }

    describe '.published' do
      it 'returns only published stories' do
        expect(Story.published).to include(published_story, romance_story, fantasy_story, popular_story, recent_story, old_story)
        expect(Story.published).not_to include(draft_story)
      end
    end

    describe '.drafts' do
      it 'returns only draft stories' do
        expect(Story.drafts).to include(draft_story)
        expect(Story.drafts).not_to include(published_story)
      end
    end

    describe '.by_category' do
      it 'returns stories in Romance category' do
        expect(Story.by_category('Romance')).to include(romance_story)
        expect(Story.by_category('Romance')).not_to include(fantasy_story)
      end

      it 'returns stories in Fantasy category' do
        expect(Story.by_category('Fantasy')).to include(fantasy_story)
        expect(Story.by_category('Fantasy')).not_to include(romance_story)
      end
    end

    describe '.by_language' do
      it 'returns English stories' do
        expect(Story.by_language('en')).to include(english_story)
        expect(Story.by_language('en')).not_to include(indonesian_story)
      end

      it 'returns Indonesian stories' do
        expect(Story.by_language('id')).to include(indonesian_story)
        expect(Story.by_language('id')).not_to include(english_story)
      end
    end

    describe '.recent' do
      it 'returns stories ordered by created_at desc' do
        expect(Story.recent.first).to eq(recent_story)
        expect(Story.recent.last).to eq(old_story)
      end
    end

    describe '.popular' do
      it 'returns stories ordered by view_count desc' do
        expect(Story.popular.first).to eq(popular_story)
      end
    end
  end

  describe '#increment_views!' do
    let(:story) { create(:story, view_count: 0) }

    it 'increments the view count by 1' do
      expect { story.increment_views! }.to change { story.reload.view_count }.from(0).to(1)
    end

    it 'increments multiple times' do
      story.increment_views!
      story.increment_views!
      expect(story.reload.view_count).to eq(2)
    end
  end

  describe '#language_name' do
    it 'returns English for en' do
      story = build(:story, language: 'en')
      expect(story.language_name).to eq('English')
    end

    it 'returns Bahasa Indonesia for id' do
      story = build(:story, language: 'id')
      expect(story.language_name).to eq('Bahasa Indonesia')
    end

    it 'returns Bahasa Melayu for ms' do
      story = build(:story, language: 'ms')
      expect(story.language_name).to eq('Bahasa Melayu')
    end

    it 'returns the code itself for unknown language' do
      story = Story.new(language: 'unknown')
      expect(story.language_name).to eq('unknown')
    end
  end

  describe 'Epic 2: Authoring (Dashboard & Book Creation)' do
    let(:author) { create(:user) }

    context 'create a new story with all Epic 2 fields' do
      it 'creates a story with title, description, language, category, and cover' do
        story = author.stories.create!(
          title: 'My First Story',
          description: 'This is a test story',
          language: 'en',
          category: 'Romance',
          status: 'draft'
        )

        expect(story).to be_persisted
        expect(story.title).to eq('My First Story')
        expect(story.description).to eq('This is a test story')
        expect(story.language).to eq('en')
        expect(story.category).to eq('Romance')
        expect(story.status).to eq('draft')
        expect(story.user).to eq(author)
      end

      it 'can attach a cover image' do
        story = create(:story)
        story.cover_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'test_cover.png',
          content_type: 'image/png'
        )

        expect(story.cover_image).to be_attached
        expect(story.cover_image.filename.to_s).to eq('test_cover.png')
      end
    end

    context 'edit a story after creation' do
      let(:story) { create(:story, title: 'Original Title', language: 'en', category: 'Fantasy') }

      it 'can update title' do
        story.update!(title: 'Updated Title')
        expect(story.reload.title).to eq('Updated Title')
      end

      it 'can update description' do
        story.update!(description: 'Updated description')
        expect(story.reload.description).to eq('Updated description')
      end

      it 'can update language' do
        story.update!(language: 'id')
        expect(story.reload.language).to eq('id')
      end

      it 'can update category' do
        story.update!(category: 'Romance')
        expect(story.reload.category).to eq('Romance')
      end

      it 'can change from draft to published' do
        story.update!(status: 'published')
        expect(story.reload.status).to eq('published')
      end
    end

    context 'dashboard story listing' do
      let!(:draft1) { create(:story, user: author, status: 'draft', title: 'Draft 1') }
      let!(:draft2) { create(:story, user: author, status: 'draft', title: 'Draft 2') }
      let!(:published1) { create(:story, user: author, status: 'published', title: 'Published 1') }
      let!(:published2) { create(:story, user: author, status: 'published', title: 'Published 2') }
      let!(:other_user_story) { create(:story, status: 'published', title: 'Other User') }

      it 'shows all stories for the author' do
        my_stories = author.stories
        expect(my_stories).to include(draft1, draft2, published1, published2)
        expect(my_stories).not_to include(other_user_story)
      end

      it 'separates published and draft stories' do
        published = author.stories.published
        drafts = author.stories.drafts

        expect(published).to include(published1, published2)
        expect(published).not_to include(draft1, draft2)

        expect(drafts).to include(draft1, draft2)
        expect(drafts).not_to include(published1, published2)
      end
    end
  end

  describe 'cascading deletes' do
    let(:story) { create(:story) }

    it 'destroys associated chapters when story is destroyed' do
      create_list(:chapter, 3, story: story)
      expect { story.destroy }.to change { Chapter.count }.by(-3)
    end
  end

  describe 'counter cache' do
    let(:story) { create(:story) }

    it 'updates chapters_count when chapters are added' do
      expect { create(:chapter, story: story) }.to change { story.reload.chapters_count }.by(1)
    end

    it 'updates chapters_count when chapters are removed' do
      chapter = create(:chapter, story: story)
      expect { chapter.destroy }.to change { story.reload.chapters_count }.by(-1)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:story)).to be_valid
    end

    it 'has a valid published factory' do
      expect(build(:story, :published)).to be_valid
    end

    it 'creates with chapters via trait' do
      story = create(:story, :with_chapters, chapters_count: 3)
      expect(story.chapters.count).to eq(3)
    end
  end
end
