require "test_helper"

class StoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stories_url
    assert_response :success
  end

  test "should get show" do
    get story_url(stories(:one))
    assert_response :success
  end

  test "should get new" do
    sign_in_as(users(:one))
    get new_story_url
    assert_response :success
  end

  test "should get edit" do
    sign_in_as(users(:one))
    get edit_story_url(stories(:one))
    assert_response :success
  end
end
