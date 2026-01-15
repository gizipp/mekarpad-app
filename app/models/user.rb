class User < ApplicationRecord
  # Stories
  has_many :stories, dependent: :destroy

  # Reading lists
  has_many :reading_lists, dependent: :destroy
  has_many :saved_stories, through: :reading_lists, source: :story

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  # Generate a 6-digit OTP code
  def generate_otp!
    self.otp_code = rand(100000..999999).to_s
    self.otp_sent_at = Time.current
    save!
  end

  # Check if OTP is valid (correct code and not expired)
  def valid_otp?(code)
    return false if otp_code.blank? || otp_sent_at.blank?
    return false if otp_sent_at < 15.minutes.ago # OTP expires after 15 minutes

    otp_code == code
  end

  # Clear OTP after successful verification
  def clear_otp!
    update!(otp_code: nil, otp_sent_at: nil)
  end

  # Placeholder methods for features not yet implemented (Epic 3)
  def coin_balance
    0
  end

  def can_unlock_chapter?(chapter)
    false
  end
end
