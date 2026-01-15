class DashboardController < ApplicationController
  before_action :require_login

  def index
    @current_user = current_user

    # Stories and chapters
    @stories = current_user.stories.includes(:chapters).order(updated_at: :desc).limit(10)
    @total_stories = current_user.stories.count
    @published_stories = current_user.stories.published.count
    @draft_stories = current_user.stories.drafts.count
  end

  private

  def require_login
    unless current_user
      redirect_to new_session_path, alert: "Please sign in"
    end
  end
end
