require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe 'associations' do
    it { should belong_to(:story).counter_cache(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:order) }
    it { should validate_length_of(:title).is_at_least(1).is_at_most(200) }
    it { should validate_numericality_of(:order).only_integer.is_greater_than(0) }

    context 'order uniqueness within story' do
      let(:story) { create(:story) }
      let!(:chapter1) { create(:chapter, story: story, order: 1) }

      it 'allows same order in different stories' do
        other_story = create(:story)
        chapter2 = build(:chapter, story: other_story, order: 1)
        expect(chapter2).to be_valid
      end

      it 'prevents duplicate order in same story' do
        chapter2 = build(:chapter, story: story, order: 1)
        expect(chapter2).not_to be_valid
      end
    end
  end

  describe 'default scope' do
    let(:story) { create(:story) }
    let!(:chapter3) { create(:chapter, story: story, order: 3) }
    let!(:chapter1) { create(:chapter, story: story, order: 1) }
    let!(:chapter2) { create(:chapter, story: story, order: 2) }

    it 'orders chapters by order ascending' do
      expect(story.chapters.to_a).to eq([ chapter1, chapter2, chapter3 ])
    end
  end

  describe '#next_chapter' do
    let(:story) { create(:story) }
    let!(:chapter1) { create(:chapter, story: story, order: 1) }
    let!(:chapter2) { create(:chapter, story: story, order: 2) }
    let!(:chapter3) { create(:chapter, story: story, order: 3) }

    it 'returns the next chapter' do
      expect(chapter1.next_chapter).to eq(chapter2)
      expect(chapter2.next_chapter).to eq(chapter3)
    end

    it 'returns nil for the last chapter' do
      expect(chapter3.next_chapter).to be_nil
    end
  end

  describe '#previous_chapter' do
    let(:story) { create(:story) }
    let!(:chapter1) { create(:chapter, story: story, order: 1) }
    let!(:chapter2) { create(:chapter, story: story, order: 2) }
    let!(:chapter3) { create(:chapter, story: story, order: 3) }

    it 'returns the previous chapter' do
      expect(chapter3.previous_chapter).to eq(chapter2)
      expect(chapter2.previous_chapter).to eq(chapter1)
    end

    it 'returns nil for the first chapter' do
      expect(chapter1.previous_chapter).to be_nil
    end
  end

  describe 'Epic 3: Writing (Chapter Editor)' do
    let(:author) { create(:user) }
    let(:story) { create(:story, user: author) }

    context 'creating a chapter' do
      it 'creates a chapter with title, content, and order' do
        chapter = story.chapters.create!(
          title: 'Chapter 1: The Beginning',
          content: 'Once upon a time...',
          order: 1
        )

        expect(chapter).to be_persisted
        expect(chapter.title).to eq('Chapter 1: The Beginning')
        expect(chapter.content.to_plain_text).to eq('Once upon a time...')
        expect(chapter.order).to eq(1)
      end

      it 'allows creating chapters sequentially' do
        chapter1 = create(:chapter, story: story, order: 1)
        chapter2 = create(:chapter, story: story, order: 2)
        chapter3 = create(:chapter, story: story, order: 3)

        expect(story.chapters.count).to eq(3)
        expect(story.chapters.pluck(:order)).to eq([ 1, 2, 3 ])
      end

      it 'defaults to draft status when created' do
        chapter = create(:chapter, story: story)
        expect(chapter.status).to eq('draft')
        expect(chapter).to be_draft
      end
    end

    context 'status validations' do
      it 'validates presence of status' do
        chapter = build(:chapter, status: nil)
        expect(chapter).not_to be_valid
        expect(chapter.errors[:status]).to include("can't be blank")
      end

      it 'only allows draft or published status' do
        chapter = build(:chapter, status: 'archived')
        expect(chapter).not_to be_valid
        expect(chapter.errors[:status]).to include('archived is not a valid status')
      end

      it 'allows draft status' do
        chapter = build(:chapter, status: 'draft')
        expect(chapter).to be_valid
      end

      it 'allows published status' do
        chapter = build(:chapter, status: 'published')
        expect(chapter).to be_valid
      end
    end

    context 'draft and published scopes' do
      let!(:draft1) { create(:chapter, :draft, story: story) }
      let!(:draft2) { create(:chapter, :draft, story: story) }
      let!(:published1) { create(:chapter, :published, story: story) }
      let!(:published2) { create(:chapter, :published, story: story) }

      it 'returns only draft chapters' do
        expect(Chapter.drafts).to contain_exactly(draft1, draft2)
      end

      it 'returns only published chapters' do
        expect(Chapter.published).to contain_exactly(published1, published2)
      end
    end

    context 'status helper methods' do
      it 'draft? returns true for draft chapters' do
        chapter = create(:chapter, :draft)
        expect(chapter.draft?).to be true
        expect(chapter.published?).to be false
      end

      it 'published? returns true for published chapters' do
        chapter = create(:chapter, :published)
        expect(chapter.published?).to be true
        expect(chapter.draft?).to be false
      end
    end

    context 'publishing a draft' do
      let(:draft_chapter) { create(:chapter, :draft, story: story, title: 'Draft Chapter') }

      it 'can publish a draft chapter' do
        expect { draft_chapter.publish! }.to change { draft_chapter.status }.from('draft').to('published')
      end

      it 'saves the published status to database' do
        draft_chapter.publish!
        expect(draft_chapter.reload.status).to eq('published')
      end

      it 'published chapter is accessible via published scope' do
        draft_chapter.publish!
        expect(Chapter.published).to include(draft_chapter)
      end
    end

    context 'unpublishing a chapter' do
      let(:published_chapter) { create(:chapter, :published, story: story, title: 'Published Chapter') }

      it 'can unpublish a published chapter' do
        expect { published_chapter.unpublish! }.to change { published_chapter.status }.from('published').to('draft')
      end

      it 'saves the draft status to database' do
        published_chapter.unpublish!
        expect(published_chapter.reload.status).to eq('draft')
      end

      it 'unpublished chapter is accessible via drafts scope' do
        published_chapter.unpublish!
        expect(Chapter.drafts).to include(published_chapter)
      end
    end

    context 'editing and re-saving a chapter' do
      let(:chapter) { create(:chapter, story: story, title: 'Original Title', content: 'Original content') }

      it 'can update title' do
        chapter.update!(title: 'Updated Title')
        expect(chapter.reload.title).to eq('Updated Title')
      end

      it 'can update content to fix typos' do
        chapter.update!(content: 'Updated content with typo fixes')
        expect(chapter.reload.content.to_plain_text).to eq('Updated content with typo fixes')
      end

      it 'can update both title and content' do
        chapter.update!(
          title: 'Revised Chapter Title',
          content: 'Completely rewritten content'
        )
        expect(chapter.reload.title).to eq('Revised Chapter Title')
        expect(chapter.reload.content.to_plain_text).to eq('Completely rewritten content')
      end

      it 'can edit and re-save a published chapter' do
        published_chapter = create(:chapter, :published, story: story, title: 'Published', content: 'Original')
        published_chapter.update!(content: 'Fixed typo')

        expect(published_chapter.reload.content.to_plain_text).to eq('Fixed typo')
        expect(published_chapter.status).to eq('published') # Stays published
      end
    end

    context 'distraction-free writing' do
      it 'supports rich text content with ActionText' do
        chapter = create(:chapter, story: story)
        expect(chapter).to respond_to(:content)
        expect(chapter.content).to be_a(ActionText::RichText)
      end

      it 'allows long-form content' do
        long_content = 'Lorem ipsum ' * 1000  # ~12,000 characters
        chapter = create(:chapter, story: story, content: long_content)
        expect(chapter.reload.content.to_plain_text.length).to be > 10000
      end
    end

    context 'auto-save simulation' do
      let(:chapter) { create(:chapter, story: story, title: 'Chapter 1', content: 'Initial content') }

      it 'updates immediately upon saving (simulating auto-save)' do
        original_updated_at = chapter.updated_at

        sleep 0.1  # Small delay to ensure updated_at changes
        chapter.update!(content: 'Updated via auto-save')

        expect(chapter.updated_at).to be > original_updated_at
        expect(chapter.reload.content.to_plain_text).to eq('Updated via auto-save')
      end

      it 'preserves draft status during auto-save' do
        draft = create(:chapter, :draft, story: story, content: 'Original')
        draft.update!(content: 'Auto-saved content')

        expect(draft.reload.status).to eq('draft')
      end

      it 'preserves published status during edits' do
        published = create(:chapter, :published, story: story, content: 'Original')
        published.update!(content: 'Edited content')

        expect(published.reload.status).to eq('published')
      end
    end

    context '10-minute publishing flow (Epic 3 metric)' do
      it 'completes full flow: create draft -> edit -> publish in minimal steps' do
        # Step 1: Create draft (1 action)
        chapter = create(:chapter, :draft, story: story, title: 'My Chapter', content: 'Initial draft')
        expect(chapter).to be_draft

        # Step 2: Edit content (1 action)
        chapter.update!(content: 'Revised content')
        expect(chapter.reload.content.to_plain_text).to eq('Revised content')

        # Step 3: Publish (1 action)
        chapter.publish!
        expect(chapter).to be_published

        # Total: 3 simple actions - easily completable in under 10 minutes
      end
    end
  end

  describe 'counter cache' do
    let(:story) { create(:story) }

    it 'increments story chapters_count when chapter is created' do
      expect { create(:chapter, story: story) }.to change { story.reload.chapters_count }.by(1)
    end

    it 'decrements story chapters_count when chapter is destroyed' do
      chapter = create(:chapter, story: story)
      expect { chapter.destroy }.to change { story.reload.chapters_count }.by(-1)
    end

    it 'maintains accurate count with multiple chapters' do
      create_list(:chapter, 5, story: story)
      expect(story.reload.chapters_count).to eq(5)
    end
  end

  describe 'cascading deletes' do
    let(:story) { create(:story) }
    let(:chapter) { create(:chapter, story: story) }

    it 'is destroyed when story is destroyed' do
      chapter  # Create the chapter
      expect { story.destroy }.to change { Chapter.count }.by(-1)
    end
  end

  describe 'Epic 4: navigation between chapters' do
    let(:story) { create(:story) }
    let!(:chapter1) { create(:chapter, story: story, order: 1, title: 'Chapter 1') }
    let!(:chapter2) { create(:chapter, story: story, order: 2, title: 'Chapter 2') }
    let!(:chapter3) { create(:chapter, story: story, order: 3, title: 'Chapter 3') }

    it 'supports seamless next/previous navigation' do
      # From chapter 1, can navigate to chapter 2
      expect(chapter1.next_chapter).to eq(chapter2)
      expect(chapter1.previous_chapter).to be_nil

      # From chapter 2, can navigate both ways
      expect(chapter2.next_chapter).to eq(chapter3)
      expect(chapter2.previous_chapter).to eq(chapter1)

      # From chapter 3, can navigate to chapter 2
      expect(chapter3.next_chapter).to be_nil
      expect(chapter3.previous_chapter).to eq(chapter2)
    end

    it 'maintains navigation even with gaps in order numbers' do
      chapter5 = create(:chapter, story: story, order: 5, title: 'Chapter 5')
      chapter10 = create(:chapter, story: story, order: 10, title: 'Chapter 10')

      expect(chapter3.next_chapter).to eq(chapter5)
      expect(chapter5.next_chapter).to eq(chapter10)
      expect(chapter10.previous_chapter).to eq(chapter5)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:chapter)).to be_valid
    end

    it 'creates with sequential orders' do
      story = create(:story)
      chapters = create_list(:chapter, 3, story: story)
      expect(chapters.map(&:order).sort).to eq([ 1, 2, 3 ])
    end
  end
end
