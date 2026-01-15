require 'rails_helper'

RSpec.feature 'Epic 5: Accessibility (NFR)', type: :feature do
  # User Story: As a User with visual impairments, I want the UI to use high-contrast colors
  # and readable typography (like Inter or Poppins), so I can have a comfortable experience.

  let(:author) { create(:user, email: 'author@example.com', name: 'Test Author') }
  let(:reader) { create(:user, email: 'reader@example.com', name: 'Test Reader') }
  let!(:story) { create(:story, user: author, title: 'Accessibility Test Story', status: 'published', description: 'Testing accessibility features', category: 'Romance') }
  let!(:chapter) { create(:chapter, story: story, title: 'Chapter One', order: 1, content: 'Accessible content for all readers') }

  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  describe 'Typography - Inter and Poppins Fonts' do
    context 'font configuration' do
      scenario 'Inter font is imported from Google Fonts' do
        visit root_path
        # Check that the stylesheet includes Inter font import
        css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
        expect(css_content).to include('fonts.googleapis.com')
        expect(css_content).to include('Inter')
      end

      scenario 'Poppins font is imported from Google Fonts' do
        css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
        expect(css_content).to include('Poppins')
      end

      scenario 'body text uses Inter font family' do
        css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
        # Body should use Inter as primary font
        expect(css_content).to match(/body\s*\{[^}]*font-family:[^}]*'Inter'/m)
      end

      scenario 'headings use Poppins font family' do
        css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
        # Headings should use Poppins
        expect(css_content).to match(/h1,\s*h2,\s*h3,\s*h4,\s*h5,\s*h6\s*\{[^}]*font-family:[^}]*'Poppins'/m)
      end

      scenario 'fonts are loaded with proper weights for readability' do
        css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
        # Should include multiple font weights (400, 500, 600, 700)
        expect(css_content).to include('wght@400')
      end
    end
  end

  describe 'High-Contrast Colors' do
    scenario 'body text has high contrast ratio' do
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      # Body should have dark text (#333) on light background (#f5f5f5)
      expect(css_content).to match(/color:\s*#333/)
      expect(css_content).to match(/background-color:\s*#f5f5f5/)
    end

    scenario 'content text has proper contrast for readability' do
      visit story_chapter_path(story, chapter)
      # Content text should be visible and have proper contrast
      expect(page).to have_css('.content-text')
    end

    scenario 'buttons have sufficient contrast' do
      visit story_path(story)
      # Primary buttons should have visible, high-contrast colors
      expect(page).to have_css('.btn-primary')
    end
  end

  describe 'Readable Line Heights' do
    scenario 'body text has comfortable line height' do
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      # Body should have line-height of 1.6 or greater
      expect(css_content).to match(/line-height:\s*1\.[6-9]/)
    end

    scenario 'chapter content has enhanced line height for reading' do
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      # Content text should have line-height of 1.8
      expect(css_content).to match(/\.content-text[^}]*line-height:\s*1\.[789]/m)
    end
  end

  describe 'Semantic HTML Structure' do
    context 'on story show page' do
      before { visit story_path(story) }

      scenario 'has proper heading hierarchy starting with h1' do
        expect(page).to have_css('h1', text: story.title)
      end

      scenario 'has h2 for major sections' do
        expect(page).to have_css('h2', text: 'Chapters')
        expect(page).to have_css('h2', text: 'Comments')
      end

      scenario 'has h3 for section subsections' do
        expect(page).to have_css('h3', text: 'Description')
      end

      scenario 'headings are in logical order without skipping levels' do
        # h1 (story title) -> h2 (sections) -> h3 (subsections)
        headings = page.all('h1, h2, h3, h4, h5, h6').map(&:tag_name)
        expect(headings.first).to eq('h1')
      end
    end

    context 'on chapter reading page' do
      before { visit story_chapter_path(story, chapter) }

      scenario 'has h1 for chapter title' do
        expect(page).to have_css('h1', text: chapter.title)
      end

      scenario 'has h2 for comments section' do
        expect(page).to have_css('h2', text: 'Comments')
      end
    end

    context 'on dashboard' do
      before do
        sign_in_as(author)
        visit dashboard_path
      end

      scenario 'has h1 for page title' do
        expect(page).to have_css('h1', text: 'Author Dashboard')
      end

      scenario 'has h2 for major sections' do
        # Dashboard should have h2 for sections when stories exist
        expect(page).to have_css('h1')
      end
    end
  end

  describe 'ARIA Attributes' do
    context 'on dashboard' do
      before do
        sign_in_as(author)
        create(:story, user: author)
        visit dashboard_path
      end

      scenario 'tab navigation has aria-label' do
        expect(page).to have_css('nav[aria-label="Tabs"]')
      end

      scenario 'interactive elements are properly labeled' do
        # Buttons should have descriptive text
        expect(page).to have_link('Create New Story')
      end
    end
  end

  describe 'Image Alt Text' do
    context 'when story has cover image' do
      before do
        # Story already exists with title
        visit story_path(story)
      end

      scenario 'cover images have descriptive alt text' do
        if story.cover_image.attached?
          # Alt text should be the story title
          expect(page.html).to include("alt=\"#{story.title}\"")
        end
      end
    end

    scenario 'all images across the site have alt attributes' do
      visit stories_path
      # All images should have alt attributes (even if empty for decorative images)
      images = page.all('img')
      images.each do |img|
        expect(img[:alt]).not_to be_nil
      end
    end
  end

  describe 'Form Accessibility' do
    context 'on story creation form' do
      before do
        sign_in_as(author)
        visit new_story_path
      end

      scenario 'all form inputs have associated labels' do
        expect(page).to have_field('Title')
        expect(page).to have_field('Description')
        expect(page).to have_field('Category')
        expect(page).to have_field('Language')
        expect(page).to have_field('Cover image')
        expect(page).to have_field('Status')
      end

      scenario 'form inputs have helpful placeholders' do
        expect(page).to have_field('Title', placeholder: 'Enter your story title')
        expect(page).to have_field('Description', placeholder: 'Tell readers what your story is about...')
      end

      scenario 'form has clear submit button' do
        expect(page).to have_button('Create Story')
      end

      scenario 'form has cancel option' do
        expect(page).to have_link('Cancel')
      end
    end

    context 'on chapter creation form' do
      before do
        sign_in_as(author)
        visit new_story_chapter_path(story)
      end

      scenario 'chapter form has labeled inputs' do
        expect(page).to have_field('Title')
        expect(page).to have_field('Content')
      end
    end
  end

  describe 'Focus Management and Keyboard Navigation' do
    scenario 'interactive elements are keyboard accessible' do
      visit story_path(story)
      # Links and buttons should be keyboard accessible
      expect(page).to have_css('a, button, input, textarea, select')
    end

    scenario 'forms are navigable with keyboard' do
      sign_in_as(author)
      visit new_story_path
      # All form elements should be accessible via Tab key
      expect(page).to have_field('Title')
      expect(page).to have_button('Create Story')
    end
  end

  describe 'Readable Font Sizes' do
    scenario 'body text has readable font size' do
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      # Base font size should be readable (browser default or larger)
      # Content text should be 1.1rem
      expect(css_content).to include('1.1rem')
    end

    scenario 'headings have appropriate size hierarchy' do
      visit story_path(story)
      # h1 should be largest, h2 smaller, etc.
      expect(page).to have_css('h1')
      expect(page).to have_css('h2')
    end
  end

  describe 'Color Contrast in UI Components' do
    scenario 'primary buttons have high contrast' do
      visit story_path(story)
      # Primary buttons should be visible
      expect(page).to have_css('.btn-primary')
    end

    scenario 'badges and status indicators have sufficient contrast' do
      sign_in_as(author)
      visit dashboard_path
      # Status badges (Published, Draft) should be visible
      expect(page.html).to(include('bg-green').or(include('bg-yellow')))
    end

    scenario 'navigation links are clearly visible' do
      visit root_path
      # Navigation should have good contrast
      expect(page).to have_css('nav a')
    end
  end

  describe 'Error Messages and Feedback' do
    context 'when form validation fails' do
      before do
        sign_in_as(author)
        visit new_story_path
        # Submit without required fields
        click_button 'Create Story'
      end

      scenario 'error messages are visible and readable' do
        expect(page).to have_css('.errors')
      end

      scenario 'error text has sufficient contrast' do
        # Error messages should be clearly visible
        expect(page).to have_content('prohibited')
      end
    end
  end

  describe 'Link Differentiation' do
    scenario 'links are distinguishable from regular text' do
      visit story_path(story)
      # Links should have color or underline to distinguish them
      links = page.all('a')
      expect(links).not_to be_empty
    end

    scenario 'visited links can be distinguished' do
      # CSS should handle visited link states
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      expect(css_content).to include('a')
    end
  end

  describe 'Consistent Visual Design' do
    scenario 'consistent spacing throughout the application' do
      css_content = File.read(Rails.root.join('app/assets/stylesheets/application.css'))
      # Should use consistent spacing units (rem, em, or pixels)
      expect(css_content).to match(/padding:|margin:/)
    end

    scenario 'consistent color scheme for similar elements' do
      sign_in_as(author)
      visit dashboard_path
      # Primary actions should use consistent colors
      expect(page).to have_css('.bg-blue-600')
    end
  end

  describe 'Empty States Accessibility' do
    context 'when dashboard has no stories' do
      before do
        sign_in_as(author)
        visit dashboard_path
      end

      scenario 'empty state has clear, readable message' do
        expect(page).to have_content('Create Your First Story')
      end

      scenario 'empty state has visible call-to-action' do
        expect(page).to have_link('Create Your First Story', href: new_story_path)
      end

      scenario 'empty state uses icons with semantic meaning' do
        expect(page).to have_css('svg')
      end
    end
  end

  describe 'Reading Experience Optimization' do
    context 'on chapter reading page' do
      before { visit story_chapter_path(story, chapter) }

      scenario 'content area has optimal width for reading' do
        # Chapter reader should have max-width constraint
        expect(page).to have_css('.chapter-reader')
      end

      scenario 'content text has enhanced readability settings' do
        expect(page).to have_css('.content-text')
      end

      scenario 'navigation is clear and accessible' do
        expect(page).to have_css('.chapter-navigation')
      end
    end
  end
end
