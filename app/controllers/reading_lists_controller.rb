class ReadingListsController < ApplicationController
  before_action :require_login

  def index
    @reading_lists = current_user.reading_lists.includes(story: :user)
  end

  def create
    @story = Story.find(params[:story_id])
    @reading_list = current_user.reading_lists.build(story: @story)

    if @reading_list.save
      redirect_to @story, notice: 'Story added to your reading list!'
    else
      redirect_to @story, alert: 'Unable to add story to your reading list.'
    end
  end

  def destroy
    @reading_list = current_user.reading_lists.find(params[:id])
    @story = @reading_list.story
    @reading_list.destroy

    redirect_to @story, notice: 'Story removed from your reading list.'
  end
end
