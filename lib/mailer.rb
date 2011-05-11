class Mailer
  def self.mail_user(user, mail_hash)
    SES.send_email(mail_hash.merge(
      :to        => [user.email],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>}
    ))
  end
  def self.mail_webmaster(user, feedback)
    SES.send_email(
      :to        => [WEBMASTER_EMAIL_ADDRESS],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>},
      :subject   => "Friggin' feedback",
      :text_body => <<-END
User #{user.try(:email) || 'Anonymous'} sez:

#{feedback}
END
    )
  end
end