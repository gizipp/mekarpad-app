ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user)
    # Generate and save OTP for the user
    user.generate_otp!
    # Reload to ensure we have the fresh OTP code
    user.reload
    otp_code = user.otp_code

    # Post to create session (this will send OTP and regenerate it)
    post session_url, params: { email: user.email }

    # Reload again to get the newly generated OTP from the create action
    user.reload

    # Validate OTP to complete sign in
    post validate_otp_session_url, params: { otp_code: user.otp_code }
  end
end
