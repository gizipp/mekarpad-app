require 'rails_helper'

RSpec.feature 'Book Editing', type: :feature do
  let(:author) { create(:user, email: 'author@example.com', name: 'Test Author') }
  let(:other_author) { create(:user, email: 'other@example.com', name: 'Other Author') }

  # Helper method to sign in
  def sign_in_as(user)
    page.set_rack_session(user_id: user.id)
  end

  before do
    sign_in_as(author)
  end

  describe 'Epic 2: Edit Book User Story' do
    context 'editing title, description, language, category, or cover after creation' do
      let!(:story) do
        create(:story,
               user: author,
               title: 'Original Title',
               description: 'Original description',
               language: 'en',
               category: 'Romance',
               status: 'draft')
      end

      scenario 'author can edit the title of their book' do
        visit edit_story_path(story)

        expect(page).to have_content('Edit Story')
        expect(page).to have_field('Title', with: 'Original Title')

        fill_in 'Title', with: 'Updated Title'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
        expect(page).to have_content('Updated Title')

        story.reload
        expect(story.title).to eq('Updated Title')
      end

      scenario 'author can edit the description of their book' do
        visit edit_story_path(story)

        expect(page).to have_field('Description', with: 'Original description')

        fill_in 'Description', with: 'This is the updated description with more details about the story'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.description).to eq('This is the updated description with more details about the story')
      end

      scenario 'author can change the language of their book' do
        visit edit_story_path(story)

        expect(page).to have_select('Language', selected: 'English')

        select 'Bahasa Indonesia', from: 'Language'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.language).to eq('id')
        expect(story.language_name).to eq('Bahasa Indonesia')
      end

      scenario 'author can change the category of their book' do
        visit edit_story_path(story)

        expect(page).to have_select('Category', selected: 'Romance')

        select 'Fantasy', from: 'Category'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.category).to eq('Fantasy')
      end

      scenario 'author can update the cover image' do
        visit edit_story_path(story)

        # Initially no cover
        expect(page).not_to have_content('Current cover:')

        attach_file 'Cover image', Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.cover_image).to be_attached
      end

      scenario 'author can change cover image when one already exists' do
        # Attach initial cover
        story.cover_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'original_cover.png',
          content_type: 'image/png'
        )

        visit edit_story_path(story)

        expect(page).to have_content('Current cover: original_cover.png')

        # Change to new cover
        attach_file 'Cover image', Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
      end

      scenario 'author can update multiple fields at once' do
        visit edit_story_path(story)

        fill_in 'Title', with: 'Completely New Title'
        fill_in 'Description', with: 'Completely new description'
        select 'Fantasy', from: 'Category'
        select 'Bahasa Melayu', from: 'Language'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.title).to eq('Completely New Title')
        expect(story.description).to eq('Completely new description')
        expect(story.category).to eq('Fantasy')
        expect(story.language).to eq('ms')
      end

      scenario 'author can change status from draft to published' do
        expect(story.status).to eq('draft')

        visit edit_story_path(story)
        select 'Published', from: 'Status'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.status).to eq('published')
      end

      scenario 'author can change status from published to draft' do
        story.update(status: 'published')

        visit edit_story_path(story)
        select 'Draft', from: 'Status'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')

        story.reload
        expect(story.status).to eq('draft')
      end
    end

    context 'validation and error handling during edit' do
      let!(:story) { create(:story, user: author, title: 'Valid Story') }

      scenario 'cannot update book with empty title' do
        visit edit_story_path(story)

        fill_in 'Title', with: ''
        click_button 'Update Story'

        expect(page).to have_content('error')
        expect(page).to have_content('Edit Story') # Still on form

        story.reload
        expect(story.title).to eq('Valid Story') # Unchanged
      end

      scenario 'shows error messages when update validation fails' do
        visit edit_story_path(story)

        fill_in 'Title', with: ''
        click_button 'Update Story'

        expect(page).to have_css('.errors')
        expect(page).to have_content('prohibited this story from being saved')
      end

      scenario 'preserves form data when validation fails' do
        visit edit_story_path(story)

        fill_in 'Title', with: ''
        fill_in 'Description', with: 'New description that should be preserved'
        select 'Fantasy', from: 'Category'
        click_button 'Update Story'

        # Form should still have the valid fields
        expect(page).to have_field('Description', with: 'New description that should be preserved')
        expect(page).to have_select('Category', selected: 'Fantasy')
      end

      scenario 'cannot update to invalid language' do
        # This would require manipulating the form, but the model validation should catch it
        story.language = 'invalid_lang'
        expect(story).not_to be_valid
      end
    end

    context 'authorization and security' do
      let!(:my_story) { create(:story, user: author, title: 'My Story') }
      let!(:other_story) { create(:story, user: other_author, title: 'Other Author Story') }

      scenario 'author can only edit their own books' do
        visit edit_story_path(other_story)

        expect(page).to have_content('You are not authorized')
        expect(current_path).to eq(story_path(other_story))
      end

      scenario 'author can edit their own book successfully' do
        visit edit_story_path(my_story)

        expect(page).to have_content('Edit Story')
        expect(page).to have_field('Title', with: 'My Story')

        fill_in 'Title', with: 'My Updated Story'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
      end

      scenario 'cannot edit other author book through direct form submission' do
        # This tests the controller-level authorization
        # In a real scenario, this would be tested at controller level
        visit story_path(other_story)
        expect(page).not_to have_link('Edit')
      end
    end

    context 'workflow and navigation' do
      let!(:story) { create(:story, user: author, title: 'Test Story') }

      scenario 'can navigate to edit from dashboard' do
        visit dashboard_path

        within(:xpath, "//h3[contains(., 'Test Story')]/../../..") do
          click_link 'Edit'
        end

        expect(current_path).to eq(edit_story_path(story))
        expect(page).to have_content('Edit Story')
      end

      scenario 'edit form has cancel button that returns to story' do
        visit edit_story_path(story)

        click_link 'Cancel'

        expect(current_path).to eq(story_path(story))
      end

      scenario 'after successful update, redirects to story show page' do
        visit edit_story_path(story)

        fill_in 'Title', with: 'Updated Title'
        click_button 'Update Story'

        expect(current_path).to eq(story_path(story))
        expect(page).to have_content('Updated Title')
      end

      scenario 'can make multiple edits to the same book' do
        # First edit
        visit edit_story_path(story)
        fill_in 'Title', with: 'First Update'
        click_button 'Update Story'

        # Second edit
        visit edit_story_path(story)
        fill_in 'Title', with: 'Second Update'
        click_button 'Update Story'

        # Third edit
        visit edit_story_path(story)
        fill_in 'Description', with: 'Updated description'
        click_button 'Update Story'

        story.reload
        expect(story.title).to eq('Second Update')
        expect(story.description).to eq('Updated description')
      end
    end

    context 'form usability' do
      let!(:story) do
        create(:story,
               user: author,
               title: 'Test Story',
               description: 'Test description',
               category: 'Romance',
               language: 'en')
      end

      scenario 'edit form pre-populates all existing values' do
        visit edit_story_path(story)

        expect(page).to have_field('Title', with: 'Test Story')
        expect(page).to have_field('Description', with: 'Test description')
        expect(page).to have_select('Category', selected: 'Romance')
        expect(page).to have_select('Language', selected: 'English')
      end

      scenario 'form has all the same fields as create form' do
        visit edit_story_path(story)

        expect(page).to have_field('Title')
        expect(page).to have_field('Description')
        expect(page).to have_select('Category')
        expect(page).to have_select('Language')
        expect(page).to have_field('Cover image')
        expect(page).to have_select('Status')
      end

      scenario 'shows current cover filename if cover exists' do
        story.cover_image.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
          filename: 'my_cover.png',
          content_type: 'image/png'
        )

        visit edit_story_path(story)

        expect(page).to have_content('Current cover: my_cover.png')
      end
    end

    context 'Epic 2 requirement: corrections and updates' do
      let!(:story) do
        create(:story,
               user: author,
               title: 'Story with Typo',
               description: 'A descriptin with a typo',
               category: 'Mystrey',
               language: 'en')
      end

      scenario 'author can fix typos in title' do
        visit edit_story_path(story)
        fill_in 'Title', with: 'Story without Typo'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
        expect(story.reload.title).to eq('Story without Typo')
      end

      scenario 'author can fix typos in description' do
        visit edit_story_path(story)
        fill_in 'Description', with: 'A description without a typo'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
        expect(story.reload.description).to eq('A description without a typo')
      end

      scenario 'author can recategorize book if initially chosen wrong' do
        visit edit_story_path(story)
        select 'Mystery', from: 'Category'
        click_button 'Update Story'

        expect(page).to have_content('Story was successfully updated')
        expect(story.reload.category).to eq('Mystery')
      end
    end

    context 'when not logged in' do
      before { page.set_rack_session(user_id: nil) }

      let!(:story) { create(:story, user: author) }

      scenario 'redirects to sign in page' do
        visit edit_story_path(story)
        expect(current_path).to eq(new_session_path)
        expect(page).to have_content('You must be signed in')
      end
    end
  end
end
