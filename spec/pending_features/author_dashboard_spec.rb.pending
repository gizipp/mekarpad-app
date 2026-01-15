require 'rails_helper'

RSpec.feature 'Author Dashboard', type: :feature do
  let(:author) { create(:user, email: 'author@example.com', name: 'Test Author') }

  # Helper method to sign in
  def sign_in_as(user)
    # Directly set session for feature tests
    # In a real test, you'd need to extract the token and visit the magic link URL
    page.set_rack_session(user_id: user.id)
  end

  describe 'Epic 2: Author Dashboard User Stories' do
    context 'as a new Author visiting dashboard for the first time (Empty State - Critical)' do
      before do
        sign_in_as(author)
        visit dashboard_path
      end

      scenario 'sees a clear call-to-action to create first book' do
        expect(page).to have_content('Create Your First Story')
        expect(page).to have_content('Start your writing journey')
      end

      scenario 'has a prominent Create button in empty state' do
        expect(page).to have_link('Create Your First Story', href: new_story_path)
      end

      scenario 'sees Author Dashboard heading' do
        expect(page).to have_content('Author Dashboard')
      end

      scenario 'sees zero counts for all metrics' do
        expect(page).to have_content('Total Stories')
        expect(page).to have_content('Published')
        expect(page).to have_content('Drafts')

        # Check the counts are 0
        within('.bg-white.border.border-gray-200.rounded-lg.p-6.shadow-sm', match: :first) do
          expect(page).to have_content('0')
        end
      end

      scenario 'empty state has clear visual design with icon' do
        expect(page).to have_css('svg') # Icon present
        expect(page).to have_css('.bg-blue-50') # Proper styling for empty state
      end

      scenario 'clicking Create button takes to new story form' do
        click_link 'Create Your First Story'
        expect(current_path).to eq(new_story_path)
        expect(page).to have_content('Create New Story')
      end
    end

    context 'as an Author with existing books' do
      let!(:draft1) { create(:story, user: author, status: 'draft', title: 'My Draft Novel', description: 'A work in progress', updated_at: 2.days.ago) }
      let!(:draft2) { create(:story, user: author, status: 'draft', title: 'Another Draft', description: 'Still writing this', updated_at: 1.day.ago) }
      let!(:published1) { create(:story, user: author, status: 'published', title: 'Published Romance', description: 'A love story', category: 'Romance', updated_at: 3.days.ago) }
      let!(:published2) { create(:story, user: author, status: 'published', title: 'Published Fantasy', description: 'Epic adventure', category: 'Fantasy', updated_at: Time.current) }
      let!(:other_author_story) { create(:story, status: 'published', title: 'Someone Else Story') }

      before do
        sign_in_as(author)
        visit dashboard_path
      end

      scenario 'sees all my books on the dashboard' do
        expect(page).to have_content('My Draft Novel')
        expect(page).to have_content('Another Draft')
        expect(page).to have_content('Published Romance')
        expect(page).to have_content('Published Fantasy')
        expect(page).not_to have_content('Someone Else Story')
      end

      scenario 'books are clearly separated into Published and Draft with badges' do
        # Check for published badges
        within(:xpath, "//h3[contains(., 'Published Romance')]/..") do
          expect(page).to have_content('Published')
          expect(page).to have_css('.bg-green-100')
        end

        within(:xpath, "//h3[contains(., 'Published Fantasy')]/..") do
          expect(page).to have_content('Published')
          expect(page).to have_css('.bg-green-100')
        end

        # Check for draft badges
        within(:xpath, "//h3[contains(., 'My Draft Novel')]/..") do
          expect(page).to have_content('Draft')
          expect(page).to have_css('.bg-yellow-100')
        end

        within(:xpath, "//h3[contains(., 'Another Draft')]/..") do
          expect(page).to have_content('Draft')
          expect(page).to have_css('.bg-yellow-100')
        end
      end

      scenario 'sees correct counts in stats overview' do
        expect(page).to have_content('Total Stories')
        expect(page).to have_content('4') # 2 drafts + 2 published

        # Published count
        within('.bg-white.border.border-gray-200.rounded-lg.p-6.shadow-sm', text: 'Published') do
          expect(page).to have_content('2')
        end

        # Drafts count
        within('.bg-white.border.border-gray-200.rounded-lg.p-6.shadow-sm', text: 'Drafts') do
          expect(page).to have_content('2')
        end
      end

      scenario 'can quickly find and navigate to each book' do
        click_link 'Published Romance'
        expect(current_path).to eq(story_path(published1))
        expect(page).to have_content('Published Romance')
      end

      scenario 'can edit books from dashboard' do
        within(:xpath, "//h3[contains(., 'My Draft Novel')]/../../..") do
          click_link 'Edit'
        end
        expect(current_path).to eq(edit_story_path(draft1))
        expect(page).to have_content('Edit Story')
      end

      scenario 'can view books from dashboard' do
        within(:xpath, "//h3[contains(., 'Published Fantasy')]/../../..") do
          click_link 'View'
        end
        expect(current_path).to eq(story_path(published2))
      end

      scenario 'stories show relevant metadata' do
        expect(page).to have_content('Romance')
        expect(page).to have_content('Fantasy')
        expect(page).to have_content('views')
        expect(page).to have_content('chapters')
      end

      scenario 'stories are ordered by most recently updated first' do
        story_titles = page.all('.text-xl.font-semibold').map(&:text)
        expect(story_titles[0]).to eq('Published Fantasy') # Most recent
        expect(story_titles[1]).to eq('Another Draft')
        expect(story_titles[2]).to eq('My Draft Novel')
        expect(story_titles[3]).to eq('Published Romance') # Oldest
      end

      scenario 'has Create New Story button at top' do
        expect(page).to have_link('Create New Story', href: new_story_path)
      end

      scenario 'does not show empty state when stories exist' do
        expect(page).not_to have_content('Start your writing journey')
        expect(page).to have_content('My Stories')
      end
    end

    context 'with more than 10 stories' do
      before do
        create_list(:story, 12, user: author)
        sign_in_as(author)
        visit dashboard_path
      end

      scenario 'shows only 10 most recent stories' do
        story_cards = page.all('.border.border-gray-200.rounded-lg.p-4')
        expect(story_cards.count).to eq(10)
      end

      scenario 'shows link to view all stories' do
        expect(page).to have_link('View All My Stories')
      end

      scenario 'total count shows all 12 stories' do
        within('.bg-white.border.border-gray-200.rounded-lg.p-6.shadow-sm', match: :first) do
          expect(page).to have_content('12')
        end
      end
    end

    context 'when not logged in' do
      scenario 'redirects to sign in page' do
        visit dashboard_path
        expect(current_path).to eq(new_session_path)
        expect(page).to have_content('Please sign in')
      end
    end
  end

  describe 'Dashboard navigation and UX' do
    before do
      create(:story, user: author, status: 'draft', title: 'Test Story')
      sign_in_as(author)
      visit dashboard_path
    end

    scenario 'page is responsive and well-structured' do
      expect(page).to have_css('.container')
      expect(page).to have_css('.mx-auto')
    end

    scenario 'has proper headings hierarchy' do
      expect(page).to have_css('h1', text: 'Author Dashboard')
      expect(page).to have_css('h2', text: 'My Stories')
    end
  end
end
