class UserMailer
  def self.mail_user(user, mail_hash)
    SES.send_email(mail_hash.merge(
      :to        => [user.email],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>}
    ))
  end
end