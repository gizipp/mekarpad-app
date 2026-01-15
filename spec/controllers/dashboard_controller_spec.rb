require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #index' do
    context 'when user is logged in' do
      before { session[:user_id] = user.id }

      it 'returns a successful response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns current user to @current_user' do
        get :index
        expect(assigns(:current_user)).to eq(user)
      end

      context 'with no stories (empty state)' do
        it 'assigns empty array to @stories' do
          get :index
          expect(assigns(:stories)).to be_empty
        end

        it 'assigns 0 to all story counts' do
          get :index
          expect(assigns(:total_stories)).to eq(0)
          expect(assigns(:published_stories)).to eq(0)
          expect(assigns(:draft_stories)).to eq(0)
        end

        it 'renders the index template with empty state' do
          get :index
          expect(response).to render_template(:index)
        end
      end

      context 'with existing stories' do
        let!(:draft_story1) { create(:story, user: user, status: 'draft', title: 'Draft 1', updated_at: 3.days.ago) }
        let!(:draft_story2) { create(:story, user: user, status: 'draft', title: 'Draft 2', updated_at: 2.days.ago) }
        let!(:published_story1) { create(:story, user: user, status: 'published', title: 'Published 1', updated_at: 1.day.ago) }
        let!(:published_story2) { create(:story, user: user, status: 'published', title: 'Published 2', updated_at: Time.current) }
        let!(:other_user_story) { create(:story, status: 'published', title: 'Other User Story') }

        it 'assigns user stories to @stories' do
          get :index
          expect(assigns(:stories)).to match_array([ draft_story1, draft_story2, published_story1, published_story2 ])
          expect(assigns(:stories)).not_to include(other_user_story)
        end

        it 'orders stories by updated_at desc (most recent first)' do
          get :index
          stories = assigns(:stories)
          expect(stories[0]).to eq(published_story2)
          expect(stories[1]).to eq(published_story1)
          expect(stories[2]).to eq(draft_story2)
          expect(stories[3]).to eq(draft_story1)
        end

        it 'includes chapters association to avoid N+1 queries' do
          create(:chapter, story: published_story1)
          get :index
          expect(assigns(:stories).first.association(:chapters).loaded?).to be true
        end

        it 'assigns correct total stories count' do
          get :index
          expect(assigns(:total_stories)).to eq(4)
        end

        it 'assigns correct published stories count' do
          get :index
          expect(assigns(:published_stories)).to eq(2)
        end

        it 'assigns correct draft stories count' do
          get :index
          expect(assigns(:draft_stories)).to eq(2)
        end

        it 'limits results to 10 stories' do
          create_list(:story, 12, user: user)
          get :index
          expect(assigns(:stories).size).to eq(10)
        end

        it 'counts all stories even when limited to 10' do
          create_list(:story, 12, user: user)
          get :index
          expect(assigns(:total_stories)).to eq(16) # 4 existing + 12 new
        end
      end

      context 'Epic 2: Author Dashboard requirements' do
        context 'new author with no stories (Critical - Empty State)' do
          it 'displays empty state with call-to-action' do
            get :index
            expect(response).to be_successful
            expect(assigns(:stories)).to be_empty
          end
        end

        context 'author with existing books' do
          let!(:draft1) { create(:story, user: user, status: 'draft', title: 'My Draft Book') }
          let!(:draft2) { create(:story, user: user, status: 'draft', title: 'Another Draft') }
          let!(:published1) { create(:story, user: user, status: 'published', title: 'Published Book 1') }
          let!(:published2) { create(:story, user: user, status: 'published', title: 'Published Book 2') }
          let!(:published3) { create(:story, user: user, status: 'published', title: 'Published Book 3') }

          it 'shows all author books' do
            get :index
            expect(assigns(:stories).count).to eq(5)
          end

          it 'separates published and draft counts' do
            get :index
            expect(assigns(:published_stories)).to eq(3)
            expect(assigns(:draft_stories)).to eq(2)
          end

          it 'provides data for Published and Draft lists' do
            get :index
            stories = assigns(:stories)
            published = stories.select { |s| s.status == 'published' }
            drafts = stories.select { |s| s.status == 'draft' }

            expect(published.count).to eq(3)
            expect(drafts.count).to eq(2)
          end
        end
      end
    end

    context 'when user is not logged in' do
      it 'redirects to sign in page' do
        get :index
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets alert flash message' do
        get :index
        expect(flash[:alert]).to eq('Please sign in')
      end

      it 'does not assign any instance variables' do
        get :index
        expect(assigns(:stories)).to be_nil
        expect(assigns(:total_stories)).to be_nil
      end
    end
  end
end
