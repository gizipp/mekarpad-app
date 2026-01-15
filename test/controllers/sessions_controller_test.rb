require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should get verify" do
    # Set pending_user_id in session as if user just requested OTP
    post session_url, params: { email: users(:one).email }
    get verify_session_url
    assert_response :success
  end
end
