require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "otp_email" do
    user = users(:one)
    mail = UserMailer.otp_email(user)
    assert_equal "Your verification code is #{user.otp_code}", mail.subject
    assert_equal [user.email], mail.to
    assert_match user.otp_code, mail.body.encoded
  end
end
