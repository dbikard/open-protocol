WEBMASTER_EMAIL_ADDRESS = "".freeze
raise "You must specify an email address for the webmaster." if WEBMASTER_EMAIL_ADDRESS.blank?
FROM_EMAIL_ADDRESS = "".freeze
raise "You must specify an email address from which the application can send email." if FROM_EMAIL_ADDRESS.blank?
require 'yaml'
ses_credentials = YAML.load(File.read(Rails.root.join("config", "ses.yml")))
SES = AWS::SES::Base.new(ses_credentials[Rails.env].symbolize_keys)