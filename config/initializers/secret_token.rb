# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

SECRET_TOKEN = ""
raise 'No secret is defined in SECRET_TOKEN in config/initializers/secret_token.rb' if SECRET_TOKEN.blank?
OpenProtocol::Application.config.secret_token = SECRET_TOKEN
