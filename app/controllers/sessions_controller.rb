class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :verify, :validate_otp ]

  def new
    # Show sign in form
  end

  def create
    email = params[:email]&.downcase&.strip

    if email.blank?
      flash[:alert] = "Please enter your email address"
      redirect_to new_session_path and return
    end

    # Find or create user by email
    user = User.find_or_initialize_by(email: email)

    if user.new_record?
      user.name = email.split("@").first # Default name from email
      unless user.save
        flash[:alert] = "Invalid email address"
        redirect_to new_session_path and return
      end
    end

    # Generate and send OTP
    user.generate_otp!

    # Send OTP via email
    UserMailer.otp_email(user).deliver_later

    # Store user_id in session to verify OTP later
    session[:pending_user_id] = user.id

    flash[:notice] = "We've sent a verification code to #{user.email}"
    redirect_to verify_session_path
  end

  def verify
    # Show OTP verification form
    @user = User.find_by(id: session[:pending_user_id])
    redirect_to new_session_path unless @user
  end

  def validate_otp
    user = User.find_by(id: session[:pending_user_id])

    unless user
      flash[:alert] = "Session expired. Please sign in again."
      redirect_to new_session_path and return
    end

    otp_code = params[:otp_code]

    if user.valid_otp?(otp_code)
      # Clear OTP and log in user
      user.clear_otp!
      session[:user_id] = user.id
      session.delete(:pending_user_id)

      flash[:notice] = "Successfully signed in!"
      redirect_to dashboard_path
    else
      # Check if OTP is expired or invalid
      if user.otp_sent_at && user.otp_sent_at < 15.minutes.ago
        flash[:alert] = "Your verification code has expired. Please request a new one below."
      else
        flash[:alert] = "Invalid verification code. Please check and try again."
      end
      redirect_to verify_session_path
    end
  end

  def resend_otp
    user = User.find_by(id: session[:pending_user_id])

    unless user
      flash[:alert] = "Session expired. Please sign in again."
      redirect_to new_session_path and return
    end

    # Generate and send new OTP
    user.generate_otp!
    UserMailer.otp_email(user).deliver_later

    flash[:notice] = "A new verification code has been sent to #{user.email}"
    redirect_to verify_session_path
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been signed out"
    redirect_to new_session_path
  end
end
