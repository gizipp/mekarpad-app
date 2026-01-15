require 'rails_helper'

RSpec.describe ChaptersController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:story) { create(:story, user: user) }
  let(:chapter) { create(:chapter, story: story) }

  describe 'GET #show' do
    it 'returns a successful response' do
      get :show, params: { story_id: story.id, id: chapter.id }
      expect(response).to be_successful
    end

    it 'assigns the requested chapter to @chapter' do
      get :show, params: { story_id: story.id, id: chapter.id }
      expect(assigns(:chapter)).to eq(chapter)
    end

    it 'assigns comments to @comments' do
      create_list(:comment, 3, commentable: chapter)
      get :show, params: { story_id: story.id, id: chapter.id }
      expect(assigns(:comments).count).to eq(3)
    end

    it 'orders comments by recent first' do
      get :show, params: { story_id: story.id, id: chapter.id }
      comments = assigns(:comments)
      if comments.size > 1
        expect(comments.first.created_at).to be >= comments.last.created_at
      end
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'updates reading progress' do
        expect {
          get :show, params: { story_id: story.id, id: chapter.id }
        }.to change { ReadingProgress.count }.by(1)
      end

      it 'sets the correct chapter in reading progress' do
        get :show, params: { story_id: story.id, id: chapter.id }
        progress = ReadingProgress.find_by(user: user, story: story)
        expect(progress.chapter).to eq(chapter)
      end
    end

    context 'when user is not logged in' do
      it 'does not update reading progress' do
        expect {
          get :show, params: { story_id: story.id, id: chapter.id }
        }.not_to change { ReadingProgress.count }
      end
    end

    it 'does not require authentication' do
      get :show, params: { story_id: story.id, id: chapter.id }
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'GET #new' do
    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :new, params: { story_id: story.id }
        expect(response).to be_successful
      end

      it 'assigns a new chapter to @chapter' do
        get :new, params: { story_id: story.id }
        expect(assigns(:chapter)).to be_a_new(Chapter)
      end

      it 'sets order to next available number' do
        create(:chapter, story: story, order: 3)
        get :new, params: { story_id: story.id }
        expect(assigns(:chapter).order).to eq(4)
      end

      it 'sets order to 1 for first chapter' do
        get :new, params: { story_id: story.id }
        expect(assigns(:chapter).order).to eq(1)
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'redirects to story page' do
        get :new, params: { story_id: story.id }
        expect(response).to redirect_to(story)
      end

      it 'sets alert flash message' do
        get :new, params: { story_id: story.id }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get :new, params: { story_id: story.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:chapter) }
    let(:invalid_attributes) { attributes_for(:chapter, title: '') }

    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      context 'with valid attributes' do
        it 'creates a new chapter' do
          expect {
            post :create, params: { story_id: story.id, chapter: valid_attributes }
          }.to change { Chapter.count }.by(1)
        end

        it 'associates chapter with the story' do
          post :create, params: { story_id: story.id, chapter: valid_attributes }
          expect(Chapter.last.story).to eq(story)
        end

        it 'redirects to the created chapter' do
          post :create, params: { story_id: story.id, chapter: valid_attributes }
          expect(response).to redirect_to(story_chapter_path(story, Chapter.last))
        end

        it 'sets success flash message' do
          post :create, params: { story_id: story.id, chapter: valid_attributes }
          expect(flash[:notice]).to eq('Chapter was successfully created.')
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new chapter' do
          expect {
            post :create, params: { story_id: story.id, chapter: invalid_attributes }
          }.not_to change { Chapter.count }
        end

        it 'renders the new template' do
          post :create, params: { story_id: story.id, chapter: invalid_attributes }
          expect(response).to render_template(:new)
        end

        it 'returns unprocessable entity status' do
          post :create, params: { story_id: story.id, chapter: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'does not create a chapter' do
        expect {
          post :create, params: { story_id: story.id, chapter: valid_attributes }
        }.not_to change { Chapter.count }
      end

      it 'redirects to story page' do
        post :create, params: { story_id: story.id, chapter: valid_attributes }
        expect(response).to redirect_to(story)
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :edit, params: { story_id: story.id, id: chapter.id }
        expect(response).to be_successful
      end

      it 'assigns the requested chapter to @chapter' do
        get :edit, params: { story_id: story.id, id: chapter.id }
        expect(assigns(:chapter)).to eq(chapter)
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'redirects to story page' do
        get :edit, params: { story_id: story.id, id: chapter.id }
        expect(response).to redirect_to(story)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { title: 'Updated Chapter', content: 'Updated content' } }

    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      context 'with valid attributes' do
        it 'updates the chapter' do
          patch :update, params: { story_id: story.id, id: chapter.id, chapter: new_attributes }
          chapter.reload
          expect(chapter.title).to eq('Updated Chapter')
          expect(chapter.content).to eq('Updated content')
        end

        it 'redirects to the chapter' do
          patch :update, params: { story_id: story.id, id: chapter.id, chapter: new_attributes }
          expect(response).to redirect_to(story_chapter_path(story, chapter))
        end

        it 'sets success flash message' do
          patch :update, params: { story_id: story.id, id: chapter.id, chapter: new_attributes }
          expect(flash[:notice]).to eq('Chapter was successfully updated.')
        end
      end

      context 'with invalid attributes' do
        it 'does not update the chapter' do
          original_title = chapter.title
          patch :update, params: { story_id: story.id, id: chapter.id, chapter: { title: '' } }
          chapter.reload
          expect(chapter.title).to eq(original_title)
        end

        it 'renders the edit template' do
          patch :update, params: { story_id: story.id, id: chapter.id, chapter: { title: '' } }
          expect(response).to render_template(:edit)
        end
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'does not update the chapter' do
        original_title = chapter.title
        patch :update, params: { story_id: story.id, id: chapter.id, chapter: new_attributes }
        chapter.reload
        expect(chapter.title).to eq(original_title)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      it 'destroys the chapter' do
        chapter # Create the chapter
        expect {
          delete :destroy, params: { story_id: story.id, id: chapter.id }
        }.to change { Chapter.count }.by(-1)
      end

      it 'redirects to the story' do
        delete :destroy, params: { story_id: story.id, id: chapter.id }
        expect(response).to redirect_to(story)
      end

      it 'sets success flash message' do
        delete :destroy, params: { story_id: story.id, id: chapter.id }
        expect(flash[:notice]).to eq('Chapter was successfully deleted.')
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'does not destroy the chapter' do
        chapter # Create the chapter
        expect {
          delete :destroy, params: { story_id: story.id, id: chapter.id }
        }.not_to change { Chapter.count }
      end
    end
  end

  describe 'Epic 3: Auto-save and Publishing' do
    let(:draft_chapter) { create(:chapter, :draft, story: story) }
    let(:published_chapter) { create(:chapter, :published, story: story) }

    describe 'PATCH #update with JSON (auto-save)' do
      before { session[:user_id] = user.id }

      context 'with valid attributes' do
        it 'returns success JSON response' do
          patch :update, params: {
            story_id: story.id,
            id: draft_chapter.id,
            chapter: { content: 'Auto-saved content' },
            format: :json
          }

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['status']).to eq('success')
        end

        it 'updates the chapter content' do
          patch :update, params: {
            story_id: story.id,
            id: draft_chapter.id,
            chapter: { content: 'Auto-saved content' },
            format: :json
          }

          expect(draft_chapter.reload.content.to_plain_text).to eq('Auto-saved content')
        end

        it 'preserves draft status during auto-save' do
          patch :update, params: {
            story_id: story.id,
            id: draft_chapter.id,
            chapter: { content: 'Auto-saved content' },
            format: :json
          }

          expect(draft_chapter.reload.status).to eq('draft')
        end

        it 'allows auto-saving published chapters' do
          patch :update, params: {
            story_id: story.id,
            id: published_chapter.id,
            chapter: { content: 'Updated published content' },
            format: :json
          }

          expect(response).to have_http_status(:ok)
          expect(published_chapter.reload.content.to_plain_text).to eq('Updated published content')
          expect(published_chapter.status).to eq('published')
        end
      end

      context 'with invalid attributes' do
        it 'returns error JSON response' do
          patch :update, params: {
            story_id: story.id,
            id: draft_chapter.id,
            chapter: { title: '' },
            format: :json
          }

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)['status']).to eq('error')
        end

        it 'includes error messages in JSON response' do
          patch :update, params: {
            story_id: story.id,
            id: draft_chapter.id,
            chapter: { title: '' },
            format: :json
          }

          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to be_present
        end
      end
    end

    describe 'PATCH #publish' do
      before { session[:user_id] = user.id }

      it 'publishes a draft chapter' do
        expect {
          patch :publish, params: { story_id: story.id, id: draft_chapter.id }
        }.to change { draft_chapter.reload.status }.from('draft').to('published')
      end

      it 'redirects to chapter show page' do
        patch :publish, params: { story_id: story.id, id: draft_chapter.id }
        expect(response).to redirect_to(story_chapter_path(story, draft_chapter))
      end

      it 'sets success flash message' do
        patch :publish, params: { story_id: story.id, id: draft_chapter.id }
        expect(flash[:notice]).to eq('Chapter was successfully published.')
      end

      context 'when user is not the story author' do
        before { session[:user_id] = other_user.id }

        it 'does not publish the chapter' do
          expect {
            patch :publish, params: { story_id: story.id, id: draft_chapter.id }
          }.not_to change { draft_chapter.reload.status }
        end

        it 'redirects to story page with alert' do
          patch :publish, params: { story_id: story.id, id: draft_chapter.id }
          expect(response).to redirect_to(story)
          expect(flash[:alert]).to eq('You are not authorized to perform this action.')
        end
      end

      context 'when user is not logged in' do
        before { session.delete(:user_id) }

        it 'redirects to sign in page' do
          patch :publish, params: { story_id: story.id, id: draft_chapter.id }
          expect(response).to redirect_to(new_session_path)
        end
      end
    end

    describe 'PATCH #unpublish' do
      before { session[:user_id] = user.id }

      it 'unpublishes a published chapter' do
        expect {
          patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
        }.to change { published_chapter.reload.status }.from('published').to('draft')
      end

      it 'redirects to edit page' do
        patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
        expect(response).to redirect_to(edit_story_chapter_path(story, published_chapter))
      end

      it 'sets success flash message' do
        patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
        expect(flash[:notice]).to eq('Chapter was unpublished and saved as draft.')
      end

      context 'when user is not the story author' do
        before { session[:user_id] = other_user.id }

        it 'does not unpublish the chapter' do
          expect {
            patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
          }.not_to change { published_chapter.reload.status }
        end

        it 'redirects to story page with alert' do
          patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
          expect(response).to redirect_to(story)
          expect(flash[:alert]).to eq('You are not authorized to perform this action.')
        end
      end

      context 'when user is not logged in' do
        before { session.delete(:user_id) }

        it 'redirects to sign in page' do
          patch :unpublish, params: { story_id: story.id, id: published_chapter.id }
          expect(response).to redirect_to(new_session_path)
        end
      end
    end

    describe 'POST #create with status' do
      before { session[:user_id] = user.id }

      it 'creates a chapter as draft' do
        post :create, params: {
          story_id: story.id,
          chapter: attributes_for(:chapter, status: 'draft')
        }

        expect(Chapter.last.status).to eq('draft')
      end

      it 'creates a chapter as published' do
        post :create, params: {
          story_id: story.id,
          chapter: attributes_for(:chapter, status: 'published')
        }

        expect(Chapter.last.status).to eq('published')
      end
    end

    describe 'Complete Epic 3 workflow' do
      before { session[:user_id] = user.id }

      it 'supports full draft -> edit -> publish workflow' do
        # Step 1: Create a draft chapter
        post :create, params: {
          story_id: story.id,
          chapter: attributes_for(:chapter, title: 'My Chapter', status: 'draft')
        }

        new_chapter = Chapter.last
        expect(new_chapter.status).to eq('draft')

        # Step 2: Auto-save edits via JSON
        patch :update, params: {
          story_id: story.id,
          id: new_chapter.id,
          chapter: { content: 'Updated content' },
          format: :json
        }

        expect(response).to have_http_status(:ok)
        expect(new_chapter.reload.content.to_plain_text).to eq('Updated content')

        # Step 3: Publish the chapter
        patch :publish, params: { story_id: story.id, id: new_chapter.id }

        expect(new_chapter.reload.status).to eq('published')
        expect(flash[:notice]).to eq('Chapter was successfully published.')
      end

      it 'allows editing and re-saving published chapters' do
        # Create a published chapter
        chapter = create(:chapter, :published, story: story, content: 'Original content')

        # Edit the published chapter
        patch :update, params: {
          story_id: story.id,
          id: chapter.id,
          chapter: { content: 'Fixed typo' }
        }

        expect(chapter.reload.content.to_plain_text).to eq('Fixed typo')
        expect(chapter.status).to eq('published') # Remains published
      end
    end
  end
end
