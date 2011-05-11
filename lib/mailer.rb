class Mailer
  HOST = "openprotocols.net"

  def self.mail_user(user, mail_hash)
    SES.send_email(mail_hash.merge(
      :to        => [user.email],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>}
    ))
  end
  def self.mail_webmaster(user, ref, feedback)
    SES.send_email(
      :to        => [WEBMASTER_EMAIL_ADDRESS],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>},
      :subject   => "Friggin' feedback",
      :text_body => <<-END
User #{user.try(:email) || 'Anonymous'} from #{ref} sez:

#{feedback}
END
    )
  end
  def self.mail_welcome(user)
    SES.send_email(
      :to        => [user.email],
      :source    => %{"OpenProtocols" <#{FROM_EMAIL_ADDRESS}>},
      :subject   => "openProtocol Registration",
      :text_body => <<-END
Welcome to openProtocol #{user.name}!

You can see your collected protocols here:
#{Rails.application.routes.url_helpers.my_collections_url(:host => HOST)}

And read more about the openProtocol project here:
#{Rails.application.routes.url_helpers.about_url(:host => HOST)}

Thanks for joining!
The openProtocol team
END
    )
  end
end