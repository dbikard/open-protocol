# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
OpenProtocol::Application.initialize!
ActiveRecord::Base.include_root_in_json = false
SANITIZE_OPTIONS = {
  :elements => ['a', 'p', 'em', 'strong'],
  :attributes => { 'a' => ['href', 'title'] },
  :protocols  => { 'a' => { 'href' => ['http', 'https'] } },
  :add_attributes => {
    'a' => {'rel' => 'nofollow'}
  }
}.freeze