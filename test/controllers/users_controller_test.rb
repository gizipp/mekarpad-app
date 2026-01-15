require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    sign_in_as(users(:one))
    get edit_user_url
    assert_response :success
  end
end
