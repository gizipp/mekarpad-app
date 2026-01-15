require 'rails_helper'

RSpec.feature 'Book Creation', type: :feature do
  let(:author) { create(:user, email: 'author@example.com', name: 'Test Author') }

  # Helper method to sign in
  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  before do
    sign_in_as(author)
  end

  describe 'Epic 2: Book Creation User Story' do
    context 'creating a new book with all required fields' do
      scenario 'author successfully creates a book with title, description, language, category, and cover' do
        visit new_story_path

        expect(page).to have_content('Create New Story')

        # Fill in all Epic 2 required fields
        fill_in 'Title', with: 'My Amazing Novel'
        fill_in 'Description', with: 'This is a compelling story about adventure and romance'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'

        # Attach cover image
        attach_file 'Cover image', Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')

        # Choose status
        select 'Draft', from: 'Status'

        click_button 'Create Story'

        # Verify success
        expect(page).to have_content('Story was successfully created')
        expect(page).to have_content('My Amazing Novel')
        expect(page).to have_content('This is a compelling story about adventure and romance')
      end

      scenario 'author can create a book with all languages' do
        # Test English
        visit new_story_path
        fill_in 'Title', with: 'English Story'
        fill_in 'Description', with: 'An English story'
        select 'English', from: 'Language'
        select 'Fantasy', from: 'Category'
        click_button 'Create Story'
        expect(page).to have_content('Story was successfully created')

        # Test Bahasa Indonesia
        visit new_story_path
        fill_in 'Title', with: 'Cerita Indonesia'
        fill_in 'Description', with: 'Sebuah cerita dalam Bahasa Indonesia'
        select 'Bahasa Indonesia', from: 'Language'
        select 'Romance', from: 'Category'
        click_button 'Create Story'
        expect(page).to have_content('Story was successfully created')

        # Test Bahasa Melayu
        visit new_story_path
        fill_in 'Title', with: 'Kisah Melayu'
        fill_in 'Description', with: 'Sebuah kisah dalam Bahasa Melayu'
        select 'Bahasa Melayu', from: 'Language'
        select 'Mystery', from: 'Category'
        click_button 'Create Story'
        expect(page).to have_content('Story was successfully created')
      end

      scenario 'author can create a book in all available categories' do
        categories = [ 'Romance', 'Fantasy', 'Mystery', 'Thriller', 'SciFi', 'Horror', 'Adventure' ]

        categories.each do |category|
          visit new_story_path
          fill_in 'Title', with: "#{category} Story"
          fill_in 'Description', with: "A #{category} story"
          select category, from: 'Category'
          select 'English', from: 'Language'
          click_button 'Create Story'
          expect(page).to have_content('Story was successfully created')
        end
      end

      scenario 'author can create a book as draft or published' do
        # Create as draft
        visit new_story_path
        fill_in 'Title', with: 'Draft Story'
        fill_in 'Description', with: 'A draft story'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'
        select 'Draft', from: 'Status'
        click_button 'Create Story'

        story = Story.find_by(title: 'Draft Story')
        expect(story.status).to eq('draft')

        # Create as published
        visit new_story_path
        fill_in 'Title', with: 'Published Story'
        fill_in 'Description', with: 'A published story'
        select 'Fantasy', from: 'Category'
        select 'English', from: 'Language'
        select 'Published', from: 'Status'
        click_button 'Create Story'

        story = Story.find_by(title: 'Published Story')
        expect(story.status).to eq('published')
      end

      scenario 'newly created book is discoverable by language and category' do
        visit new_story_path
        fill_in 'Title', with: 'Discoverable Romance'
        fill_in 'Description', with: 'A romance story in English'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'
        select 'Published', from: 'Status'
        click_button 'Create Story'

        # Verify the book can be found by category and language
        story = Story.find_by(title: 'Discoverable Romance')
        expect(story.category).to eq('Romance')
        expect(story.language).to eq('en')
        expect(Story.by_category('Romance')).to include(story)
        expect(Story.by_language('en')).to include(story)
      end
    end

    context 'validation and error handling' do
      scenario 'cannot create book without title' do
        visit new_story_path
        fill_in 'Description', with: 'A story without title'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'
        click_button 'Create Story'

        expect(page).to have_content('error')
        expect(page).to have_content('Create New Story') # Still on form page
      end

      scenario 'cannot create book without category' do
        visit new_story_path
        fill_in 'Title', with: 'Story Without Category'
        fill_in 'Description', with: 'A story'
        select 'English', from: 'Language'
        # Don't select category
        click_button 'Create Story'

        # Should fail validation
        expect(page).to have_content('Create New Story')
      end

      scenario 'shows error messages when validation fails' do
        visit new_story_path
        # Leave title empty
        fill_in 'Description', with: 'Description only'
        click_button 'Create Story'

        expect(page).to have_css('.errors')
        expect(page).to have_content('prohibited this story from being saved')
      end

      scenario 'preserves form data when validation fails' do
        visit new_story_path
        fill_in 'Description', with: 'My precious description'
        select 'Fantasy', from: 'Category'
        # Leave title empty
        click_button 'Create Story'

        # Form should still have the description
        expect(page).to have_field('Description', with: 'My precious description')
        expect(page).to have_select('Category', selected: 'Fantasy')
      end
    end

    context 'form usability' do
      scenario 'form has all required fields visible and labeled' do
        visit new_story_path

        expect(page).to have_field('Title')
        expect(page).to have_field('Description')
        expect(page).to have_select('Category')
        expect(page).to have_select('Language')
        expect(page).to have_field('Cover image')
        expect(page).to have_select('Status')
      end

      scenario 'form has helpful placeholders' do
        visit new_story_path

        expect(page).to have_field('Title', placeholder: 'Enter your story title')
        expect(page).to have_field('Description', placeholder: 'Tell readers what your story is about...')
      end

      scenario 'form has cancel button to go back' do
        visit new_story_path

        expect(page).to have_link('Cancel', href: stories_path)
      end

      scenario 'language dropdown shows full language names' do
        visit new_story_path

        expect(page).to have_select('Language', options: [ 'English', 'Bahasa Indonesia', 'Bahasa Melayu' ])
      end
    end

    context 'workflow from dashboard to creation' do
      scenario 'can navigate from empty dashboard to create book' do
        visit dashboard_path
        click_link 'Create Your First Story'

        expect(current_path).to eq(new_story_path)
        expect(page).to have_content('Create New Story')
      end

      scenario 'can navigate from dashboard with stories to create new book' do
        create(:story, user: author, title: 'Existing Story')
        visit dashboard_path

        click_link 'Create New Story'

        expect(current_path).to eq(new_story_path)
        expect(page).to have_content('Create New Story')
      end

      scenario 'after creating book, can navigate back to dashboard' do
        visit new_story_path
        fill_in 'Title', with: 'New Book'
        fill_in 'Description', with: 'Description'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'
        click_button 'Create Story'

        # Now navigate to dashboard
        visit dashboard_path

        expect(page).to have_content('New Book')
        expect(page).to have_content('Author Dashboard')
      end
    end

    context 'Author Activation goal' do
      scenario 'new author can create first book within simple flow' do
        # This tests the "Publishing Time" metric: first-time authors can publish a book within 10 minutes
        # We simulate a quick creation flow

        # Step 1: Visit dashboard (empty state)
        visit dashboard_path
        expect(page).to have_content('Create Your First Story')

        # Step 2: Click create
        click_link 'Create Your First Story'

        # Step 3: Fill minimal required fields quickly
        fill_in 'Title', with: 'My First Book'
        fill_in 'Description', with: 'My first attempt at writing'
        select 'Romance', from: 'Category'
        select 'English', from: 'Language'
        # Leave cover optional for speed
        select 'Published', from: 'Status'

        # Step 4: Submit
        click_button 'Create Story'

        # Step 5: Verify success
        expect(page).to have_content('Story was successfully created')
        expect(page).to have_content('My First Book')

        # Verify the story exists and is published
        story = Story.find_by(title: 'My First Book')
        expect(story).to be_present
        expect(story.status).to eq('published')
        expect(story.user).to eq(author)

        # This flow demonstrates that Author Activation goal (30% of new users create at least one book) is achievable
      end
    end

    context 'when not logged in' do
      before { page.set_rack_session(user_id: nil) }

      scenario 'redirects to sign in page' do
        visit new_story_path
        expect(current_path).to eq(new_session_path)
        expect(page).to have_content('You must be signed in')
      end
    end
  end
end
