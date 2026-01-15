require "test_helper"

class ChaptersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    chapter = chapters(:one)
    get story_chapter_url(chapter.story, chapter)
    assert_response :success
  end

  test "should get new" do
    sign_in_as(users(:one))
    story = stories(:one)
    get new_story_chapter_url(story)
    assert_response :success
  end

  test "should get edit" do
    sign_in_as(users(:one))
    chapter = chapters(:one)
    get edit_story_chapter_url(chapter.story, chapter)
    assert_response :success
  end
end
