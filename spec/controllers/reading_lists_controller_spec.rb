require 'rails_helper'

RSpec.describe ReadingListsController, type: :controller do
  let(:user) { create(:user) }
  let(:story) { create(:story) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
        create_list(:reading_list, 3, user: user)
      end

      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns user reading lists to @reading_lists' do
        get :index
        expect(assigns(:reading_lists).count).to eq(3)
      end

      it 'includes story and user associations to avoid N+1 queries' do
        get :index
        reading_list = assigns(:reading_lists).first
        expect(reading_list.association(:story).loaded?).to be true
        expect(reading_list.story.association(:user).loaded?).to be true
      end

      it 'only shows current user reading lists' do
        other_user = create(:user)
        other_reading_list = create(:reading_list, user: other_user)
        get :index
        expect(assigns(:reading_lists)).not_to include(other_reading_list)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'creates a new reading list entry' do
        expect {
          post :create, params: { story_id: story.id }
        }.to change { ReadingList.count }.by(1)
      end

      it 'associates reading list with current user' do
        post :create, params: { story_id: story.id }
        expect(ReadingList.last.user).to eq(user)
      end

      it 'associates reading list with story' do
        post :create, params: { story_id: story.id }
        expect(ReadingList.last.story).to eq(story)
      end

      it 'redirects to the story' do
        post :create, params: { story_id: story.id }
        expect(response).to redirect_to(story)
      end

      it 'sets success flash message' do
        post :create, params: { story_id: story.id }
        expect(flash[:notice]).to eq('Story added to your reading list!')
      end

      context 'when story is already in reading list' do
        before { create(:reading_list, user: user, story: story) }

        it 'does not create duplicate entry' do
          expect {
            post :create, params: { story_id: story.id }
          }.not_to change { ReadingList.count }
        end

        it 'sets error flash message' do
          post :create, params: { story_id: story.id }
          expect(flash[:alert]).to eq('Unable to add story to your reading list.')
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        post :create, params: { story_id: story.id }
        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a reading list entry' do
        expect {
          post :create, params: { story_id: story.id }
        }.not_to change { ReadingList.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }
      let!(:reading_list) { create(:reading_list, user: user, story: story) }

      it 'destroys the reading list entry' do
        expect {
          delete :destroy, params: { id: reading_list.id }
        }.to change { ReadingList.count }.by(-1)
      end

      it 'redirects to the story' do
        delete :destroy, params: { id: reading_list.id }
        expect(response).to redirect_to(story)
      end

      it 'sets success flash message' do
        delete :destroy, params: { id: reading_list.id }
        expect(flash[:notice]).to eq('Story removed from your reading list.')
      end
    end

    context 'when trying to delete another user reading list' do
      let(:other_user) { create(:user) }
      let(:reading_list) { create(:reading_list, user: other_user, story: story) }

      before { session[:user_id] = user.id }

      it 'raises RecordNotFound error' do
        expect {
          delete :destroy, params: { id: reading_list.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not logged in' do
      let(:reading_list) { create(:reading_list, story: story) }

      it 'redirects to sign in page' do
        delete :destroy, params: { id: reading_list.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
