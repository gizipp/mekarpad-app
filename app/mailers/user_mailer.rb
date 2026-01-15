class UserMailer < ApplicationMailer
  def otp_email(user)
    @user = user
    @otp_code = user.otp_code

    mail(
      to: user.email,
      subject: "Your verification code is #{@otp_code}"
    )
  end
end
