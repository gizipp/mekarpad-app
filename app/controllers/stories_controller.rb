class StoriesController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_story, only: [ :show, :edit, :update, :destroy ]
  before_action :require_author, only: [ :edit, :update, :destroy ]

  def index
    @stories = Story.published.recent.includes(:user).limit(20)
    @stories = @stories.by_category(params[:category]) if params[:category].present?
    @stories = @stories.by_language(params[:language]) if params[:language].present?
  end

  def my_stories
    @stories = current_user.stories.includes(:chapters).order(created_at: :desc)
  end

  def show
    @story.increment_views!
    @chapters = @story.chapters
    @comments = []  # Placeholder for Epic 3 - Comments feature
    @reading_progress = nil  # Placeholder for Epic 3 - Reading Progress feature
  end

  def new
    @story = Story.new
  end

  def create
    @story = current_user.stories.build(story_params)
    if @story.save
      redirect_to @story, notice: "Story was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @story.update(story_params)
      redirect_to @story, notice: "Story was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @story.destroy
    redirect_to stories_path, notice: "Story was successfully deleted."
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def require_author
    redirect_to @story, alert: "You are not authorized to perform this action." unless @story.user == current_user
  end

  def story_params
    params.require(:story).permit(:title, :description, :category, :status, :cover_image, :language)
  end

  def require_login
    redirect_to new_session_path, alert: "You must be signed in to perform this action." unless current_user
  end
end
