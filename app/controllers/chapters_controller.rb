class ChaptersController < ApplicationController
  before_action :require_login, except: [ :show ]
  before_action :set_story
  before_action :set_chapter, only: [ :show, :edit, :update, :destroy, :publish, :unpublish ]
  before_action :require_author, only: [ :new, :create, :edit, :update, :destroy, :publish, :unpublish ]

  def show
    @is_locked = false  # Placeholder for Epic 3 - Chapter locking feature
    @comments = []  # Placeholder for Epic 3 - Comments feature
  end

  def new
    @chapter = @story.chapters.build
    @chapter.order = @story.chapters.maximum(:order).to_i + 1
  end

  def create
    @chapter = @story.chapters.build(chapter_params)
    if @chapter.save
      redirect_to story_chapter_path(@story, @chapter), notice: "Chapter was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @chapter.update(chapter_params)
      respond_to do |format|
        format.html { redirect_to story_chapter_path(@story, @chapter), notice: "Chapter was successfully updated." }
        format.json { render json: { status: "success", message: "Auto-saved successfully" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @chapter.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @chapter.destroy
    redirect_to @story, notice: "Chapter was successfully deleted."
  end

  def publish
    @chapter.publish!
    redirect_to story_chapter_path(@story, @chapter), notice: "Chapter was successfully published."
  end

  def unpublish
    @chapter.unpublish!
    redirect_to edit_story_chapter_path(@story, @chapter), notice: "Chapter was unpublished and saved as draft."
  end

  private

  def set_story
    @story = Story.find(params[:story_id])
  end

  def set_chapter
    @chapter = @story.chapters.find(params[:id])
  end

  def require_author
    redirect_to @story, alert: "You are not authorized to perform this action." unless @story.user == current_user
  end

  def chapter_params
    params.require(:chapter).permit(:title, :content, :order, :status)
  end

  def require_login
    redirect_to new_session_path, alert: "You must be signed in to perform this action." unless current_user
  end
end
