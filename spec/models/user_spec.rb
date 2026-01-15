require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:stories).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should_not allow_value('').for(:email) }

    context 'email format validation' do
      it 'allows valid email formats' do
        valid_emails = %w[
          user@example.com
          test.user@example.co.uk
          user+tag@example.com
          user_name@example.org
        ]

        valid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).to be_valid, "#{email} should be valid"
        end
      end

      it 'rejects invalid email formats' do
        invalid_emails = %w[
          plaintext
          @example.com
          user@
          user@.com
        ]

        invalid_emails.each do |email|
          user = build(:user, email: email)
          expect(user).not_to be_valid, "#{email} should be invalid"
        end
      end
    end
  end

  describe '#generate_otp!' do
    let(:user) { create(:user) }

    it 'generates a 6-digit OTP code' do
      user.generate_otp!
      expect(user.otp_code).to match(/\A\d{6}\z/)
    end

    it 'sets otp_sent_at to current time' do
      user.generate_otp!
      expect(user.otp_sent_at).to be_within(1.second).of(Time.current)
    end

    it 'saves the user record' do
      expect { user.generate_otp! }.to change { user.reload.otp_code }.from(nil)
    end

    it 'generates different codes on consecutive calls' do
      codes = []
      10.times do
        user.generate_otp!
        codes << user.otp_code
      end
      # Very unlikely to get 10 identical codes
      expect(codes.uniq.size).to be > 1
    end
  end

  describe '#valid_otp?' do
    let(:user) { create(:user) }

    context 'with valid OTP' do
      before { user.generate_otp! }

      it 'returns true for correct code' do
        expect(user.valid_otp?(user.otp_code)).to be true
      end

      it 'returns true when OTP was just sent' do
        user.generate_otp!
        expect(user.valid_otp?(user.otp_code)).to be true
      end

      it 'returns true when OTP is 14 minutes old' do
        user.update!(otp_sent_at: 14.minutes.ago)
        expect(user.valid_otp?(user.otp_code)).to be true
      end
    end

    context 'with invalid OTP' do
      it 'returns false for incorrect code' do
        user.generate_otp!
        wrong_code = (user.otp_code.to_i + 1).to_s.rjust(6, '0')
        expect(user.valid_otp?(wrong_code)).to be false
      end

      it 'returns false when OTP is expired (15 minutes old)' do
        user.update!(otp_code: '123456', otp_sent_at: 15.minutes.ago)
        expect(user.valid_otp?('123456')).to be false
      end

      it 'returns false when OTP is expired (16 minutes old)' do
        user.update!(otp_code: '123456', otp_sent_at: 16.minutes.ago)
        expect(user.valid_otp?('123456')).to be false
      end

      it 'returns false when otp_code is blank' do
        user.update!(otp_code: nil, otp_sent_at: Time.current)
        expect(user.valid_otp?('123456')).to be false
      end

      it 'returns false when otp_sent_at is blank' do
        user.update!(otp_code: '123456', otp_sent_at: nil)
        expect(user.valid_otp?('123456')).to be false
      end

      it 'returns false when both otp_code and otp_sent_at are blank' do
        expect(user.valid_otp?('123456')).to be false
      end

      it 'returns false for nil code' do
        user.generate_otp!
        expect(user.valid_otp?(nil)).to be false
      end

      it 'returns false for empty string' do
        user.generate_otp!
        expect(user.valid_otp?('')).to be false
      end
    end
  end

  describe '#clear_otp!' do
    let(:user) { create(:user, :with_otp) }

    it 'clears the otp_code' do
      expect { user.clear_otp! }.to change { user.reload.otp_code }.to(nil)
    end

    it 'clears the otp_sent_at' do
      expect { user.clear_otp! }.to change { user.reload.otp_sent_at }.to(nil)
    end

    it 'saves the user record' do
      user.clear_otp!
      user.reload
      expect(user.otp_code).to be_nil
      expect(user.otp_sent_at).to be_nil
    end
  end

  describe 'cascading deletes' do
    let(:user) { create(:user) }

    it 'destroys associated stories when user is destroyed' do
      create_list(:story, 3, user: user)
      expect { user.destroy }.to change { Story.count }.by(-3)
    end
  end

  describe 'edge cases' do
    it 'allows users with same name but different emails' do
      user1 = create(:user, name: 'John Doe', email: 'john1@example.com')
      user2 = build(:user, name: 'John Doe', email: 'john2@example.com')
      expect(user2).to be_valid
    end

    it 'does not allow duplicate emails (case insensitive would be ideal)' do
      create(:user, email: 'test@example.com')
      duplicate = build(:user, email: 'test@example.com')
      expect(duplicate).not_to be_valid
    end

    it 'requires name to be present' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end

    it 'requires email to be present' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end

    it 'accepts bio as optional field' do
      user = build(:user, bio: nil)
      expect(user).to be_valid
    end

    it 'accepts long bio text' do
      user = build(:user, bio: 'a' * 1000)
      expect(user).to be_valid
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end

    it 'has a valid factory with OTP' do
      expect(build(:user, :with_otp)).to be_valid
    end

    it 'has a valid factory with expired OTP' do
      expect(build(:user, :with_expired_otp)).to be_valid
    end
  end
end
