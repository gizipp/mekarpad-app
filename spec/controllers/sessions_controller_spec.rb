require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end

    it 'does not require authentication' do
      get :new
      expect(response).not_to redirect_to(new_session_path)
    end
  end

  describe 'POST #create' do
    let(:email) { 'test@example.com' }

    context 'with valid email' do
      it 'creates a new user if email does not exist' do
        expect {
          post :create, params: { email: email }
        }.to change { User.count }.by(1)
      end

      it 'sets default name from email for new user' do
        post :create, params: { email: email }
        user = User.find_by(email: email)
        expect(user.name).to eq('test')
      end

      it 'does not create duplicate user if email exists' do
        existing_user = create(:user, email: email)
        expect {
          post :create, params: { email: email }
        }.not_to change { User.count }
      end

      it 'generates OTP for the user' do
        post :create, params: { email: email }
        user = User.find_by(email: email)
        expect(user.otp_code).to be_present
        expect(user.otp_sent_at).to be_present
      end

      it 'sends OTP email' do
        expect {
          post :create, params: { email: email }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it 'stores pending_user_id in session' do
        post :create, params: { email: email }
        user = User.find_by(email: email)
        expect(session[:pending_user_id]).to eq(user.id)
      end

      it 'redirects to verify page' do
        post :create, params: { email: email }
        expect(response).to redirect_to(verify_session_path)
      end

      it 'sets success flash message' do
        post :create, params: { email: email }
        expect(flash[:notice]).to include('sent a verification code')
      end

      it 'handles email with uppercase letters' do
        post :create, params: { email: 'TEST@EXAMPLE.COM' }
        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
      end

      it 'handles email with leading/trailing spaces' do
        post :create, params: { email: '  test@example.com  ' }
        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
      end

      it 'reuses existing user for subsequent sign-ins' do
        existing_user = create(:user, email: email, name: 'John Doe')
        post :create, params: { email: email }
        user = User.find_by(email: email)
        expect(user.name).to eq('John Doe') # Name should not change
      end
    end

    context 'with blank email' do
      it 'redirects to new session page' do
        post :create, params: { email: '' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets error flash message' do
        post :create, params: { email: '' }
        expect(flash[:alert]).to eq('Please enter your email address')
      end

      it 'does not create a user' do
        expect {
          post :create, params: { email: '' }
        }.not_to change { User.count }
      end

      it 'handles nil email' do
        post :create, params: { email: nil }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq('Please enter your email address')
      end
    end

    context 'with invalid email format' do
      it 'redirects to new session page' do
        post :create, params: { email: 'invalid-email' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets error flash message' do
        post :create, params: { email: 'invalid-email' }
        expect(flash[:alert]).to eq('Invalid email address')
      end

      it 'does not create a user' do
        expect {
          post :create, params: { email: 'invalid-email' }
        }.not_to change { User.count }
      end
    end
  end

  describe 'GET #verify' do
    context 'with pending_user_id in session' do
      before { session[:pending_user_id] = create(:user).id }

      it 'returns a successful response' do
        get :verify
        expect(response).to be_successful
      end
    end

    context 'without pending_user_id in session' do
      it 'redirects to new session page' do
        get :verify
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'POST #validate_otp' do
    let(:user) { create(:user, :with_otp) }

    context 'with valid OTP' do
      before { session[:pending_user_id] = user.id }

      it 'logs in the user' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(session[:user_id]).to eq(user.id)
      end

      it 'clears pending_user_id from session' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(session[:pending_user_id]).to be_nil
      end

      it 'clears OTP from user' do
        post :validate_otp, params: { otp_code: user.otp_code }
        user.reload
        expect(user.otp_code).to be_nil
        expect(user.otp_sent_at).to be_nil
      end

      it 'redirects to edit user page' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(response).to redirect_to(dashboard_path)
      end

      it 'sets success flash message' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(flash[:notice]).to eq('Successfully signed in!')
      end
    end

    context 'with invalid OTP' do
      before { session[:pending_user_id] = user.id }

      it 'does not log in the user' do
        post :validate_otp, params: { otp_code: '000000' }
        expect(session[:user_id]).to be_nil
      end

      it 'keeps pending_user_id in session' do
        post :validate_otp, params: { otp_code: '000000' }
        expect(session[:pending_user_id]).to eq(user.id)
      end

      it 'redirects to verify page' do
        post :validate_otp, params: { otp_code: '000000' }
        expect(response).to redirect_to(verify_session_path)
      end

      it 'sets error flash message' do
        post :validate_otp, params: { otp_code: '000000' }
        expect(flash[:alert]).to eq('Invalid verification code. Please check and try again.')
      end

      it 'does not clear OTP from user' do
        original_otp = user.otp_code
        post :validate_otp, params: { otp_code: '000000' }
        user.reload
        expect(user.otp_code).to eq(original_otp)
      end
    end

    context 'with expired OTP' do
      let(:user) { create(:user, :with_expired_otp) }
      before { session[:pending_user_id] = user.id }

      it 'does not log in the user' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to verify page' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(response).to redirect_to(verify_session_path)
      end

      it 'sets error flash message' do
        post :validate_otp, params: { otp_code: user.otp_code }
        expect(flash[:alert]).to eq('Your verification code has expired. Please request a new one below.')
      end
    end

    context 'without pending_user_id in session' do
      it 'redirects to new session page' do
        post :validate_otp, params: { otp_code: '123456' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets error flash message' do
        post :validate_otp, params: { otp_code: '123456' }
        expect(flash[:alert]).to eq('Session expired. Please sign in again.')
      end
    end

    context 'with invalid pending_user_id in session' do
      before { session[:pending_user_id] = 99999 }

      it 'redirects to new session page' do
        post :validate_otp, params: { otp_code: '123456' }
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets error flash message' do
        post :validate_otp, params: { otp_code: '123456' }
        expect(flash[:alert]).to eq('Session expired. Please sign in again.')
      end
    end

    context 'with nil OTP code' do
      before { session[:pending_user_id] = user.id }

      it 'does not log in the user' do
        post :validate_otp, params: { otp_code: nil }
        expect(session[:user_id]).to be_nil
      end

      it 'sets error flash message' do
        post :validate_otp, params: { otp_code: nil }
        expect(flash[:alert]).to eq('Invalid verification code. Please check and try again.')
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    context 'when logged in' do
      before { session[:user_id] = user.id }

      it 'clears user_id from session' do
        delete :destroy
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to new session page' do
        delete :destroy
        expect(response).to redirect_to(new_session_path)
      end

      it 'sets success flash message' do
        delete :destroy
        expect(flash[:notice]).to eq('You have been signed out')
      end
    end

    context 'when not logged in' do
      it 'clears user_id from session' do
        delete :destroy
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to new session page' do
        delete :destroy
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe 'authentication bypass' do
    it 'does not require login for new action' do
      get :new
      expect(response).to be_successful
    end

    it 'does not require login for create action' do
      post :create, params: { email: 'test@example.com' }
      expect(response).not_to be_server_error
    end

    it 'does not require login for verify action' do
      session[:pending_user_id] = create(:user).id
      get :verify
      expect(response).to be_successful
    end

    it 'does not require login for validate_otp action' do
      user = create(:user, :with_otp)
      session[:pending_user_id] = user.id
      post :validate_otp, params: { otp_code: user.otp_code }
      expect(response).not_to be_server_error
    end
  end
end
