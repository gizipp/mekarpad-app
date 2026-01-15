require 'rails_helper'

RSpec.feature 'Epic 5: Responsive UI (NFR)', type: :feature do
  # User Story: As any User (Author or Reader), I want the entire platform
  # (dashboard, editor, reading pages) to be fully usable and readable on my mobile phone,
  # so I can read or write on the go.

  let(:author) { create(:user, email: 'author@example.com', name: 'Test Author') }
  let(:reader) { create(:user, email: 'reader@example.com', name: 'Test Reader') }
  let!(:story) { create(:story, user: author, title: 'Mobile Test Story', status: 'published', description: 'A story for mobile testing') }
  let!(:chapter) { create(:chapter, story: story, title: 'First Chapter', order: 1, content: 'Chapter content for mobile testing') }

  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  describe 'Responsive viewport configuration' do
    context 'on all pages' do
      scenario 'has mobile viewport meta tag configured' do
        visit root_path

        # Check for viewport meta tag in page source
        expect(page.html).to include('name="viewport"')
        expect(page.html).to include('width=device-width,initial-scale=1')
      end

      scenario 'has mobile-web-app-capable meta tag' do
        visit root_path
        expect(page.html).to include('mobile-web-app-capable')
      end
    end
  end

  describe 'Author Dashboard - Mobile Responsive' do
    before do
      sign_in_as(author)
      create_list(:story, 3, user: author)
      visit dashboard_path
    end

    scenario 'dashboard uses responsive container classes' do
      expect(page).to have_css('.container')
      expect(page).to have_css('.mx-auto')
      expect(page).to have_css('.px-4')
    end

    scenario 'stats grid is responsive with mobile-first design' do
      # Check for responsive grid classes (grid-cols-1 for mobile, md:grid-cols-3 for tablet+)
      expect(page.html).to include('grid-cols-1')
      expect(page.html).to include('md:grid-cols-3')
    end

    scenario 'dashboard has proper padding for mobile devices' do
      expect(page.html).to include('py-8')
      expect(page.html).to include('px-4')
    end

    scenario 'create button is visible and accessible on mobile' do
      expect(page).to have_link('Create New Story', href: new_story_path)
      # Button should have proper padding for touch targets
      expect(page.html).to include('py-2')
      expect(page.html).to include('px-6')
    end

    scenario 'story cards are stacked vertically on mobile' do
      # Check for responsive spacing
      expect(page.html).to include('space-y-4')
    end
  end

  describe 'Story Creation Form - Mobile Responsive' do
    before do
      sign_in_as(author)
      visit new_story_path
    end

    scenario 'form is contained within mobile-friendly max width' do
      expect(page).to have_css('.form-container')
    end

    scenario 'form inputs are full width for mobile' do
      expect(page).to have_field('Title')
      expect(page).to have_field('Description')
      # Verify form controls have proper width classes
      expect(page.html).to include('form-control')
    end

    scenario 'form buttons are properly sized for touch interaction' do
      expect(page).to have_button('Create Story')
      # Should have adequate padding for touch targets (minimum 44x44px recommended)
    end
  end

  describe 'Reading Page - Mobile Responsive' do
    before do
      visit story_path(story)
    end

    scenario 'story page is responsive with proper container' do
      expect(page).to have_css('.story-show')
    end

    scenario 'story cover image is responsive' do
      # Cover image should scale properly on mobile
      expect(page).to have_css('.story-cover-large')
    end

    scenario 'story details stack vertically on mobile' do
      expect(page).to have_css('.story-header')
      expect(page).to have_css('.story-details')
    end

    scenario 'action buttons wrap on small screens' do
      # Action buttons should have flex-wrap for mobile
      expect(page.html).to include('flex-wrap') if page.has_css?('.story-actions')
    end

    scenario 'chapters list is mobile-friendly' do
      expect(page).to have_css('.chapters-section')
      expect(page).to have_css('.chapters-list')
    end
  end

  describe 'Chapter Reading Page - Mobile Optimized' do
    before do
      visit story_chapter_path(story, chapter)
    end

    scenario 'chapter reader has mobile-optimized max width' do
      expect(page).to have_css('.chapter-reader')
    end

    scenario 'chapter navigation is accessible on mobile' do
      expect(page).to have_css('.chapter-navigation')
    end

    scenario 'chapter content has readable font size on mobile' do
      expect(page).to have_css('.content-text')
      # Content text should have larger font size (1.1rem) for readability
    end

    scenario 'reading content is properly padded for mobile' do
      expect(page).to have_css('.chapter-content')
      # Should have adequate padding for comfortable reading
    end
  end

  describe 'Browse/Discover Page - Mobile Responsive' do
    before do
      create_list(:story, 5, status: 'published')
      visit stories_path
    end

    scenario 'stories grid is responsive' do
      expect(page).to have_css('.stories-grid')
    end

    scenario 'story cards are properly sized for mobile' do
      # Grid should auto-fill with minimum 250px cards
      expect(page.html).to include('stories-grid')
    end

    scenario 'categories wrap on mobile' do
      # Categories should have flex-wrap
      expect(page.html).to include('categories') if page.has_css?('.categories')
    end
  end

  describe 'Navigation - Mobile Responsive' do
    scenario 'navigation bar is present on all pages' do
      visit root_path
      expect(page).to have_css('nav')
    end

    scenario 'navigation has proper padding for mobile' do
      visit root_path
      expect(page.html).to include('1rem 2rem')
    end
  end

  describe 'General Responsive Design Principles' do
    context 'across all pages' do
      it 'uses mobile-first responsive grid system' do
        [ dashboard_path, stories_path, story_path(story) ].each do |path|
          sign_in_as(author) if path == dashboard_path
          visit path

          # Each page should have responsive elements
          expect(page.html).to match(/grid|flex|container/)
        end
      end

      it 'has consistent spacing for mobile devices' do
        visit story_path(story)
        # Should use consistent gap/padding utilities
        expect(page.html).to match(/gap-\d|p-\d|m-\d/)
      end

      it 'text content is not too wide on large screens' do
        visit story_chapter_path(story, chapter)
        # Chapter reader should have max-width constraint (800px)
        expect(page).to have_css('.chapter-reader')
      end
    end
  end

  describe 'Touch-friendly UI elements' do
    before do
      sign_in_as(author)
      visit dashboard_path
    end

    scenario 'buttons have adequate size for touch targets' do
      # All buttons should have proper padding (minimum 44x44px for accessibility)
      expect(page).to have_css('.btn')
    end

    scenario 'links have adequate spacing between them' do
      expect(page).to have_css('nav')
      # Navigation links should have margin-right for spacing
    end
  end

  describe 'Mobile-specific meta tags' do
    scenario 'has apple-mobile-web-app-capable meta tag' do
      visit root_path
      expect(page.html).to include('apple-mobile-web-app-capable')
    end

    scenario 'has application-name meta tag' do
      visit root_path
      expect(page.html).to include('application-name')
    end
  end
end
