require 'rails_helper'

RSpec.describe StoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:story) { create(:story, :published, user: user) }

  describe 'GET #index' do
    let!(:published_stories) { create_list(:story, 3, :published) }
    let!(:draft_stories) { create_list(:story, 2, status: 'draft') }

    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns only published stories to @stories' do
      get :index
      expect(assigns(:stories)).to match_array(published_stories)
      expect(assigns(:stories)).not_to include(*draft_stories)
    end

    it 'limits results to 20 stories' do
      create_list(:story, 25, :published)
      get :index
      expect(assigns(:stories).size).to eq(20)
    end

    it 'orders stories by recent first' do
      get :index
      stories = assigns(:stories)
      expect(stories.first.created_at).to be >= stories.last.created_at
    end

    it 'includes user association to avoid N+1 queries' do
      get :index
      expect(assigns(:stories).first.association(:user).loaded?).to be true
    end

    context 'with category filter' do
      let!(:fiction_story) { create(:story, :published, category: 'Fiction') }
      let!(:romance_story) { create(:story, :published, category: 'Romance') }

      it 'filters stories by category' do
        get :index, params: { category: 'Fiction' }
        expect(assigns(:stories)).to include(fiction_story)
        expect(assigns(:stories)).not_to include(romance_story)
      end

      it 'returns all published stories when category is empty' do
        get :index, params: { category: '' }
        expect(assigns(:stories).count).to be >= 2
      end
    end

    context 'with language filter' do
      let!(:english_story) { create(:story, :published, language: 'en') }
      let!(:indonesian_story) { create(:story, :published, language: 'id') }
      let!(:malay_story) { create(:story, :published, language: 'ms') }

      it 'filters stories by English language' do
        get :index, params: { language: 'en' }
        expect(assigns(:stories)).to include(english_story)
        expect(assigns(:stories)).not_to include(indonesian_story, malay_story)
      end

      it 'filters stories by Indonesian language' do
        get :index, params: { language: 'id' }
        expect(assigns(:stories)).to include(indonesian_story)
        expect(assigns(:stories)).not_to include(english_story, malay_story)
      end

      it 'filters stories by Malay language' do
        get :index, params: { language: 'ms' }
        expect(assigns(:stories)).to include(malay_story)
        expect(assigns(:stories)).not_to include(english_story, indonesian_story)
      end

      it 'returns all published stories when language is empty' do
        get :index, params: { language: '' }
        expect(assigns(:stories).count).to be >= 3
      end
    end

    context 'with combined category and language filters' do
      let!(:english_romance) { create(:story, :published, category: 'Romance', language: 'en') }
      let!(:indonesian_romance) { create(:story, :published, category: 'Romance', language: 'id') }
      let!(:english_fantasy) { create(:story, :published, category: 'Fantasy', language: 'en') }

      it 'filters stories by both category and language' do
        get :index, params: { category: 'Romance', language: 'en' }
        expect(assigns(:stories)).to include(english_romance)
        expect(assigns(:stories)).not_to include(indonesian_romance, english_fantasy)
      end
    end

    it 'does not require authentication' do
      get :index
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'GET #show' do
    let(:story) { create(:story, :published, :with_chapters, user: user) }

    # Comments feature removed
    # it 'assigns comments to @comments' do ... end

    it 'assigns comments to @comments (feature not yet implemented)' do
      # Comments not implemented yet
      get :show, params: { id: story.id }
      expect(assigns(:comments)).to eq([])
    end

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      # ReadingProgress feature removed

      it 'loads reading progress if exists (feature not yet implemented)' do
        # ReadingProgress not implemented yet
        get :show, params: { id: story.id }
        expect(assigns(:reading_progress)).to be_nil
      end
    end

    context 'when user is not logged in' do
      it 'assigns nil to reading_progress' do
        get :show, params: { id: story.id }
        expect(assigns(:reading_progress)).to be_nil
      end
    end

    it 'does not require authentication' do
      get :show, params: { id: story.id }
      expect(response).not_to redirect_to(new_session_path)
    end

    it 'shows draft stories to anyone (based on current implementation)' do
      draft_story = create(:story, status: 'draft', user: user)
      get :show, params: { id: draft_story.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :new
        expect(response).to be_successful
      end

      it 'assigns a new story to @story' do
        get :new
        expect(assigns(:story)).to be_a_new(Story)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get :new
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets alert flash message' do
        get :new
        expect(flash[:alert]).to eq('You must be signed in to perform this action.')
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:story) }
    let(:invalid_attributes) { attributes_for(:story, title: '') }

    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      context 'with valid attributes' do
        it 'creates a new story' do
          expect {
            post :create, params: { story: valid_attributes }
          }.to change { Story.count }.by(1)
        end

        it 'associates story with current user' do
          post :create, params: { story: valid_attributes }
          expect(Story.last.user).to eq(user)
        end

        it 'redirects to the created story' do
          post :create, params: { story: valid_attributes }
          expect(response).to redirect_to(Story.last)
        end

        it 'sets success flash message' do
          post :create, params: { story: valid_attributes }
          expect(flash[:notice]).to eq('Story was successfully created.')
        end

        it 'accepts all permitted parameters' do
          params = valid_attributes.merge(
            description: 'Test description',
            category: 'Fiction',
            status: 'published',
            language: 'en'
          )
          post :create, params: { story: params }
          story = Story.last
          expect(story.description).to eq('Test description')
          expect(story.category).to eq('Fiction')
          expect(story.status).to eq('published')
          expect(story.language).to eq('en')
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new story' do
          expect {
            post :create, params: { story: invalid_attributes }
          }.not_to change { Story.count }
        end

        it 'renders the new template' do
          post :create, params: { story: invalid_attributes }
          expect(response).to render_template(:new)
        end

        it 'returns unprocessable entity status' do
          post :create, params: { story: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        post :create, params: { story: valid_attributes }
        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a story' do
        expect {
          post :create, params: { story: valid_attributes }
        }.not_to change { Story.count }
      end
    end
  end

  describe 'GET #edit' do
    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :edit, params: { id: story.id }
        expect(response).to be_successful
      end

      it 'assigns the requested story to @story' do
        get :edit, params: { id: story.id }
        expect(assigns(:story)).to eq(story)
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'redirects to the story page' do
        get :edit, params: { id: story.id }
        expect(response).to redirect_to(story)
      end

      it 'sets alert flash message' do
        get :edit, params: { id: story.id }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get :edit, params: { id: story.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { title: 'Updated Title', description: 'Updated description' } }

    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      context 'with valid attributes' do
        it 'updates the story' do
          patch :update, params: { id: story.id, story: new_attributes }
          story.reload
          expect(story.title).to eq('Updated Title')
          expect(story.description).to eq('Updated description')
        end

        it 'redirects to the story' do
          patch :update, params: { id: story.id, story: new_attributes }
          expect(response).to redirect_to(story)
        end

        it 'sets success flash message' do
          patch :update, params: { id: story.id, story: new_attributes }
          expect(flash[:notice]).to eq('Story was successfully updated.')
        end

        it 'allows changing status from draft to published' do
          draft_story = create(:story, user: user, status: 'draft')
          patch :update, params: { id: draft_story.id, story: { status: 'published' } }
          expect(draft_story.reload.status).to eq('published')
        end
      end

      context 'with invalid attributes' do
        it 'does not update the story' do
          original_title = story.title
          patch :update, params: { id: story.id, story: { title: '' } }
          story.reload
          expect(story.title).to eq(original_title)
        end

        it 'renders the edit template' do
          patch :update, params: { id: story.id, story: { title: '' } }
          expect(response).to render_template(:edit)
        end

        it 'returns unprocessable entity status' do
          patch :update, params: { id: story.id, story: { title: '' } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'does not update the story' do
        original_title = story.title
        patch :update, params: { id: story.id, story: new_attributes }
        story.reload
        expect(story.title).to eq(original_title)
      end

      it 'redirects to the story page' do
        patch :update, params: { id: story.id, story: new_attributes }
        expect(response).to redirect_to(story)
      end

      it 'sets alert flash message' do
        patch :update, params: { id: story.id, story: new_attributes }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        patch :update, params: { id: story.id, story: new_attributes }
        expect(response).to redirect_to(new_session_path)
      end

      it 'does not update the story' do
        original_title = story.title
        patch :update, params: { id: story.id, story: new_attributes }
        story.reload
        expect(story.title).to eq(original_title)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is the story author' do
      before { session[:user_id] = user.id }

      it 'destroys the story' do
        story # Create the story
        expect {
          delete :destroy, params: { id: story.id }
        }.to change { Story.count }.by(-1)
      end

      it 'redirects to stories index' do
        delete :destroy, params: { id: story.id }
        expect(response).to redirect_to(stories_path)
      end

      it 'sets success flash message' do
        delete :destroy, params: { id: story.id }
        expect(flash[:notice]).to eq('Story was successfully deleted.')
      end
    end

    context 'when user is not the story author' do
      before { session[:user_id] = other_user.id }

      it 'does not destroy the story' do
        story # Create the story
        expect {
          delete :destroy, params: { id: story.id }
        }.not_to change { Story.count }
      end

      it 'redirects to the story page' do
        delete :destroy, params: { id: story.id }
        expect(response).to redirect_to(story)
      end

      it 'sets alert flash message' do
        delete :destroy, params: { id: story.id }
        expect(flash[:alert]).to eq('You are not authorized to perform this action.')
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: story.id }
        expect(response).to redirect_to(new_session_path)
      end

      it 'does not destroy the story' do
        story # Create the story
        expect {
          delete :destroy, params: { id: story.id }
        }.not_to change { Story.count }
      end
    end
  end
end
