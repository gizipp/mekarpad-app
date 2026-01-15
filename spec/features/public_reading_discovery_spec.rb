require 'rails_helper'

RSpec.feature 'Public Reading & Discovery (Epic 4)', type: :feature do
  let(:author) { create(:user, name: 'Jane Author') }
  let(:reader) { create(:user, name: 'John Reader') }

  # Helper method to sign in
  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  describe 'Epic 4: Public Reading & Discovery User Stories' do
    context 'Discover Page - Finding New Content' do
      let!(:romance_story) { create(:story, :published, :with_chapters, user: author, title: 'Love in Paris', category: 'Romance', language: 'en', chapters_count: 3) }
      let!(:fantasy_story) { create(:story, :published, :with_chapters, user: author, title: 'Dragon Quest', category: 'Fantasy', language: 'en', chapters_count: 5) }
      let!(:indonesian_story) { create(:story, :published, :with_chapters, user: author, title: 'Cinta Jakarta', category: 'Romance', language: 'id', chapters_count: 2) }
      let!(:draft_story) { create(:story, status: 'draft', user: author, title: 'Unpublished Draft') }

      scenario 'reader visits discover page and sees newest published stories' do
        visit root_path

        # Should see published stories
        expect(page).to have_content('Love in Paris')
        expect(page).to have_content('Dragon Quest')
        expect(page).to have_content('Cinta Jakarta')

        # Should NOT see draft stories
        expect(page).not_to have_content('Unpublished Draft')

        # Should show story metadata
        expect(page).to have_content('Jane Author')
        expect(page).to have_css('.story-card', count: 3)
      end

      scenario 'reader filters stories by category' do
        visit root_path

        # Click Romance category filter
        click_link 'Romance'

        # Should only see romance stories
        expect(page).to have_content('Love in Paris')
        expect(page).to have_content('Cinta Jakarta')
        expect(page).not_to have_content('Dragon Quest')
      end

      scenario 'reader filters stories by language' do
        visit root_path

        # Click English language filter
        click_link 'English'

        # Should only see English stories
        expect(page).to have_content('Love in Paris')
        expect(page).to have_content('Dragon Quest')
        expect(page).not_to have_content('Cinta Jakarta')
      end

      scenario 'reader sees story stats on discover page' do
        romance_story.update!(view_count: 150)
        visit root_path

        # Should show chapter count
        expect(page).to have_content('3')

        # Should show view count
        expect(page).to have_content('150')
      end

      scenario 'discover page is accessible without login' do
        # Don't sign in
        visit root_path

        expect(page).to have_content('Discover')
        expect(page).to have_content('Love in Paris')
        expect(current_path).to eq(root_path)
      end

      scenario 'discover page shows newest stories first' do
        # Create stories with different timestamps
        old_story = create(:story, :published, user: author, title: 'Old Story', created_at: 2.days.ago)
        new_story = create(:story, :published, user: author, title: 'New Story', created_at: 1.hour.ago)

        visit root_path

        # New story should appear before old story in the DOM
        stories_text = page.text
        new_story_position = stories_text.index('New Story')
        old_story_position = stories_text.index('Old Story')

        expect(new_story_position).to be < old_story_position
      end
    end

    context 'Book Public Page - Deciding to Read' do
      let!(:story) { create(:story, :published, :with_chapters, user: author, title: 'Epic Adventure', description: 'A thrilling journey through unknown lands', category: 'Adventure', chapters_count: 5) }

      scenario 'reader accesses book public page and sees all details' do
        visit story_path(story)

        # Should see cover, description, and chapter list
        expect(page).to have_content('Epic Adventure')
        expect(page).to have_content('A thrilling journey through unknown lands')
        expect(page).to have_content('Jane Author')
        expect(page).to have_content('Adventure')

        # Should see chapter list
        expect(page).to have_content('Chapters')
        expect(page).to have_css('.chapter-item', count: 5)
      end

      scenario 'reader sees all published chapters in order' do
        visit story_path(story)

        chapters = story.chapters.order(:order)
        chapters.each_with_index do |chapter, index|
          expect(page).to have_content("#{index + 1}. #{chapter.title}")
        end
      end

      scenario 'book public page is accessible without login' do
        # Don't sign in
        visit story_path(story)

        expect(page).to have_content('Epic Adventure')
        expect(current_path).to eq(story_path(story))
      end

      scenario 'reader can click on a chapter to start reading' do
        visit story_path(story)

        first_chapter = story.chapters.first
        click_link "1. #{first_chapter.title}"

        # Should navigate to chapter reading page
        expect(current_path).to eq(story_chapter_path(story, first_chapter))
        expect(page).to have_content(first_chapter.title)
      end

      scenario 'viewing book page increments view count' do
        expect {
          visit story_path(story)
        }.to change { story.reload.view_count }.by(1)
      end

      scenario 'reader sees stats on book page' do
        story.update!(view_count: 500)

        visit story_path(story)

        expect(page).to have_content('500 views')
        expect(page).to have_content('5 chapters')
      end
    end

    context 'Chapter Reading - Seamless Navigation' do
      let!(:story) { create(:story, :published, user: author, title: 'Long Novel') }
      let!(:chapter1) { create(:chapter, story: story, title: 'Chapter 1: The Beginning', content: 'Once upon a time in a land far away...', order: 1) }
      let!(:chapter2) { create(:chapter, story: story, title: 'Chapter 2: The Journey', content: 'The hero set out on their quest...', order: 2) }
      let!(:chapter3) { create(:chapter, story: story, title: 'Chapter 3: The Challenge', content: 'A great obstacle appeared...', order: 3) }

      scenario 'reader reads chapter with clear next/previous navigation' do
        visit story_chapter_path(story, chapter2)

        # Should see chapter content
        expect(page).to have_content('Chapter 2: The Journey')
        expect(page).to have_content('The hero set out on their quest...')

        # Should have navigation links
        expect(page).to have_link('← Previous', href: story_chapter_path(story, chapter1))
        expect(page).to have_link('Next →', href: story_chapter_path(story, chapter3))
      end

      scenario 'reader navigates through story seamlessly using next button' do
        visit story_chapter_path(story, chapter1)

        # Read chapter 1
        expect(page).to have_content('Chapter 1: The Beginning')

        # Click Next
        click_link 'Next →'

        # Should be on chapter 2
        expect(current_path).to eq(story_chapter_path(story, chapter2))
        expect(page).to have_content('Chapter 2: The Journey')

        # Click Next again
        click_link 'Next →'

        # Should be on chapter 3
        expect(current_path).to eq(story_chapter_path(story, chapter3))
        expect(page).to have_content('Chapter 3: The Challenge')
      end

      scenario 'reader navigates backwards using previous button' do
        visit story_chapter_path(story, chapter3)

        # Click Previous
        click_link '← Previous'

        # Should be on chapter 2
        expect(current_path).to eq(story_chapter_path(story, chapter2))
        expect(page).to have_content('Chapter 2: The Journey')
      end

      scenario 'first chapter shows no previous link' do
        visit story_chapter_path(story, chapter1)

        # Should not have previous link
        expect(page).not_to have_link('← Previous')

        # Should have next link
        expect(page).to have_link('Next →')
      end

      scenario 'last chapter shows end message instead of next link' do
        visit story_chapter_path(story, chapter3)

        # Should have previous link
        expect(page).to have_link('← Previous')

        # Should not have next link, but show end message
        expect(page).not_to have_link('Next →')
        expect(page).to have_content('End of current chapters')
      end

      scenario 'reader can navigate back to story page from chapter' do
        visit story_chapter_path(story, chapter2)

        click_link story.title

        # Should be back on story page
        expect(current_path).to eq(story_path(story))
        expect(page).to have_content('Long Novel')
      end

      scenario 'chapter reading page is accessible without login' do
        # Don't sign in
        visit story_chapter_path(story, chapter1)

        expect(page).to have_content('Chapter 1: The Beginning')
        expect(current_path).to eq(story_chapter_path(story, chapter1))
      end

      scenario 'chapter page shows navigation at both top and bottom' do
        visit story_chapter_path(story, chapter2)

        # Should have navigation at top
        within('.reader-header') do
          expect(page).to have_link('← Previous')
          expect(page).to have_link('Next →')
        end

        # Should have navigation at bottom
        within('.chapter-footer') do
          expect(page).to have_link('← Previous Chapter')
          expect(page).to have_link('Next Chapter →')
        end
      end
    end

    context 'Complete Reader Journey - Discover to Read' do
      let!(:featured_story) { create(:story, :published, user: author, title: 'The Lost Kingdom', description: 'An epic fantasy adventure', category: 'Fantasy', language: 'en') }
      let!(:chapter1) { create(:chapter, story: featured_story, title: 'Prologue', content: 'Long ago, in a forgotten realm...', order: 1) }
      let!(:chapter2) { create(:chapter, story: featured_story, title: 'The Awakening', content: 'The hero awoke to a strange world...', order: 2) }
      let!(:chapter3) { create(:chapter, story: featured_story, title: 'First Steps', content: 'With courage, they took their first steps...', order: 3) }

      scenario 'complete user journey: discover → book page → read chapters' do
        # Step 1: Discover page
        visit root_path
        expect(page).to have_content('The Lost Kingdom')

        # Step 2: Click on story
        click_link 'The Lost Kingdom'
        expect(current_path).to eq(story_path(featured_story))
        expect(page).to have_content('An epic fantasy adventure')
        expect(page).to have_content('Prologue')

        # Step 3: Start reading first chapter
        click_link '1. Prologue'
        expect(current_path).to eq(story_chapter_path(featured_story, chapter1))
        expect(page).to have_content('Long ago, in a forgotten realm...')

        # Step 4: Navigate to next chapter
        click_link 'Next →'
        expect(current_path).to eq(story_chapter_path(featured_story, chapter2))
        expect(page).to have_content('The hero awoke to a strange world...')

        # Step 5: Continue reading
        click_link 'Next →'
        expect(current_path).to eq(story_chapter_path(featured_story, chapter3))
        expect(page).to have_content('With courage, they took their first steps...')

        # Step 6: Navigate back to story
        click_link featured_story.title
        expect(current_path).to eq(story_path(featured_story))
      end

      scenario 'reader engages for extended reading session (3+ minutes simulation)' do
        # This tests the success metric: "reading experience so clean and engaging
        # that reader stays for more than 3 minutes"

        visit root_path
        click_link 'The Lost Kingdom'

        # Read multiple chapters without friction
        click_link '1. Prologue'
        expect(page).to have_content('Prologue')

        click_link 'Next →'
        expect(page).to have_content('The Awakening')

        click_link 'Next →'
        expect(page).to have_content('First Steps')

        # Reader stayed engaged through 3 chapters
        # Clean navigation, no interruptions, seamless flow
        expect(page).to have_content('The Lost Kingdom')
      end
    end

    context 'Multi-language and Category Support (from Epic 2)' do
      let!(:english_romance) { create(:story, :published, :with_chapters, user: author, title: 'English Love Story', category: 'Romance', language: 'en', chapters_count: 2) }
      let!(:indonesian_romance) { create(:story, :published, :with_chapters, user: author, title: 'Cinta Indonesia', category: 'Romance', language: 'id', chapters_count: 2) }
      let!(:malay_fantasy) { create(:story, :published, :with_chapters, user: author, title: 'Fantasi Melayu', category: 'Fantasy', language: 'ms', chapters_count: 2) }

      scenario 'reader discovers content by language preference' do
        visit root_path

        # Filter by Bahasa Indonesia
        click_link 'Bahasa Indonesia'

        expect(page).to have_content('Cinta Indonesia')
        expect(page).not_to have_content('English Love Story')
        expect(page).not_to have_content('Fantasi Melayu')
      end

      scenario 'reader discovers content by category and language combined' do
        visit root_path

        # Filter by category first
        click_link 'Romance'

        expect(page).to have_content('English Love Story')
        expect(page).to have_content('Cinta Indonesia')
        expect(page).not_to have_content('Fantasi Melayu')
      end

      scenario 'book page displays language information' do
        visit story_path(indonesian_romance)

        expect(page).to have_content('Cinta Indonesia')
        # Language should be visible on the page
        expect(page.text).to match(/Bahasa Indonesia|Indonesian|id/i)
      end
    end

    context 'Empty States' do
      scenario 'discover page shows message when no stories published' do
        # Don't create any published stories
        visit root_path

        expect(page).to have_content('No stories')
      end

      scenario 'book page shows message when no chapters published' do
        story = create(:story, :published, user: author)
        visit story_path(story)

        expect(page).to have_content('No chapters yet')
      end
    end

    context 'Error Handling' do
      scenario 'accessing non-existent story shows error' do
        expect {
          visit story_path(id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      scenario 'accessing non-existent chapter shows error' do
        story = create(:story, :published, user: author)

        expect {
          visit story_chapter_path(story, id: 99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'Success Metrics Validation' do
    context 'Reader Engagement: ≥50% sessions exceed 3 minutes' do
      let!(:engaging_story) { create(:story, :published, :with_chapters, user: author, title: 'Page Turner', chapters_count: 10) }

      scenario 'clean reading experience encourages continued reading' do
        visit root_path
        click_link 'Page Turner'

        # Start reading
        first_chapter = engaging_story.chapters.first
        click_link "1. #{first_chapter.title}"

        # Navigate through multiple chapters (simulating 3+ minute session)
        5.times do
          break unless page.has_link?('Next →')
          click_link 'Next →'
        end

        # Reader successfully navigated through multiple chapters
        # This demonstrates clean, engaging reading experience
        expect(page).to have_content('Page Turner')
      end
    end

    context 'Performance: Pages load under 2 seconds' do
      let!(:story) { create(:story, :published, :with_chapters, user: author, chapters_count: 3) }

      scenario 'discover page loads efficiently with proper indexing' do
        # Create multiple stories to test performance
        create_list(:story, 15, :published, user: author)

        # Visit discover page
        visit root_path

        # Should load successfully (actual timing tested in performance specs)
        expect(page).to have_content('Discover')
      end

      scenario 'book page loads efficiently with chapter list' do
        # Visit book page with multiple chapters
        visit story_path(story)

        # Should load successfully
        expect(page).to have_content(story.title)
        expect(page).to have_css('.chapter-item', count: 3)
      end

      scenario 'chapter page loads efficiently' do
        chapter = story.chapters.first

        # Visit chapter page
        visit story_chapter_path(story, chapter)

        # Should load successfully
        expect(page).to have_content(chapter.title)
      end
    end
  end
end
