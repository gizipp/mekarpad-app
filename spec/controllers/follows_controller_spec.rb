require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'POST #create' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'creates a new follow relationship' do
        expect {
          post :create, params: { user_id: other_user.id }
        }.to change { Follow.count }.by(1)
      end

      it 'adds user to following list' do
        post :create, params: { user_id: other_user.id }
        expect(user.following).to include(other_user)
      end

      it 'redirects back or to root' do
        request.env['HTTP_REFERER'] = root_path
        post :create, params: { user_id: other_user.id }
        expect(response).to redirect_to(root_path)
      end

      it 'sets success flash message' do
        post :create, params: { user_id: other_user.id }
        expect(flash[:notice]).to eq("You are now following #{other_user.name}.")
      end

      context 'when already following' do
        before { user.follow(other_user) }

        it 'does not create duplicate follow' do
          expect {
            post :create, params: { user_id: other_user.id }
          }.not_to change { Follow.count }
        end
      end

      context 'when trying to follow self' do
        it 'does not create follow relationship' do
          expect {
            post :create, params: { user_id: user.id }
          }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        post :create, params: { user_id: other_user.id }
        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a follow' do
        expect {
          post :create, params: { user_id: other_user.id }
        }.not_to change { Follow.count }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
        user.follow(other_user)
      end

      let(:follow) { user.following_relationships.find_by(followed: other_user) }

      it 'destroys the follow relationship' do
        expect {
          delete :destroy, params: { id: follow.id }
        }.to change { Follow.count }.by(-1)
      end

      it 'removes user from following list' do
        delete :destroy, params: { id: follow.id }
        expect(user.reload.following).not_to include(other_user)
      end

      it 'redirects back or to root' do
        request.env['HTTP_REFERER'] = root_path
        delete :destroy, params: { id: follow.id }
        expect(response).to redirect_to(root_path)
      end

      it 'sets success flash message' do
        delete :destroy, params: { id: follow.id }
        expect(flash[:notice]).to eq("You unfollowed #{other_user.name}.")
      end
    end

    context 'when trying to unfollow someone not following' do
      before { session[:user_id] = user.id }

      it 'raises RecordNotFound error' do
        expect {
          delete :destroy, params: { id: 99999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        delete :destroy, params: { id: 1 }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
