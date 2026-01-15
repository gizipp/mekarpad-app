require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:story) { create(:story) }
  let(:chapter) { create(:chapter) }

  describe 'POST #create' do
    context 'when commenting on a story' do
      let(:valid_attributes) { attributes_for(:comment) }

      context 'when user is logged in' do
        before { session[:user_id] = user.id }

        it 'creates a new comment' do
          expect {
            post :create, params: { story_id: story.id, comment: valid_attributes }
          }.to change { Comment.count }.by(1)
        end

        it 'associates comment with current user' do
          post :create, params: { story_id: story.id, comment: valid_attributes }
          expect(Comment.last.user).to eq(user)
        end

        it 'associates comment with story' do
          post :create, params: { story_id: story.id, comment: valid_attributes }
          expect(Comment.last.commentable).to eq(story)
        end

        it 'redirects to the story' do
          post :create, params: { story_id: story.id, comment: valid_attributes }
          expect(response).to redirect_to(story_path(story))
        end

        it 'sets success flash message' do
          post :create, params: { story_id: story.id, comment: valid_attributes }
          expect(flash[:notice]).to eq('Comment was successfully created.')
        end

        context 'with invalid attributes' do
          it 'does not create a comment' do
            expect {
              post :create, params: { story_id: story.id, comment: { content: '' } }
            }.not_to change { Comment.count }
          end

          it 'sets error flash message' do
            post :create, params: { story_id: story.id, comment: { content: '' } }
            expect(flash[:alert]).to eq('Unable to create comment.')
          end
        end
      end

      context 'when user is not logged in' do
        it 'redirects to sign in page' do
          post :create, params: { story_id: story.id, comment: valid_attributes }
          expect(response).to redirect_to(new_session_path)
        end

        it 'does not create a comment' do
          expect {
            post :create, params: { story_id: story.id, comment: valid_attributes }
          }.not_to change { Comment.count }
        end
      end
    end

    context 'when commenting on a chapter' do
      let(:valid_attributes) { attributes_for(:comment) }

      before { session[:user_id] = user.id }

      it 'creates a new comment' do
        expect {
          post :create, params: { chapter_id: chapter.id, comment: valid_attributes }
        }.to change { Comment.count }.by(1)
      end

      it 'associates comment with chapter' do
        post :create, params: { chapter_id: chapter.id, comment: valid_attributes }
        expect(Comment.last.commentable).to eq(chapter)
      end

      it 'redirects to the chapter' do
        post :create, params: { chapter_id: chapter.id, comment: valid_attributes }
        expect(response).to redirect_to(story_chapter_path(chapter.story, chapter))
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user owns the comment' do
      before { session[:user_id] = user.id }
      let(:comment) { create(:comment, :on_story, user: user, commentable: story) }

      it 'destroys the comment' do
        comment # Create the comment
        expect {
          delete :destroy, params: { id: comment.id }
        }.to change { Comment.count }.by(-1)
      end

      it 'redirects to the story' do
        delete :destroy, params: { id: comment.id }
        expect(response).to redirect_to(story_path(story))
      end

      it 'sets success flash message' do
        delete :destroy, params: { id: comment.id }
        expect(flash[:notice]).to eq('Comment was successfully deleted.')
      end

      context 'when comment is on a chapter' do
        let(:comment) { create(:comment, :on_chapter, user: user, commentable: chapter) }

        it 'redirects to the chapter' do
          delete :destroy, params: { id: comment.id }
          expect(response).to redirect_to(story_chapter_path(chapter.story, chapter))
        end
      end
    end

    context 'when user does not own the comment' do
      let(:other_user) { create(:user) }
      let(:comment) { create(:comment, :on_story, user: other_user, commentable: story) }

      before { session[:user_id] = user.id }

      it 'raises RecordNotFound error' do
        expect {
          delete :destroy, params: { id: comment.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when user is not logged in' do
      let(:comment) { create(:comment, :on_story, commentable: story) }

      it 'redirects to sign in page' do
        delete :destroy, params: { id: comment.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
