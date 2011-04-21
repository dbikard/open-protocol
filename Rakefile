# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rake'

if ARGV.grep(/rubber:/).empty?
  require File.expand_path('../config/application', __FILE__)

  OpenProtocol::Application.load_tasks
else
  load File.join(File.dirname(__FILE__), 'lib/tasks/rubber.rake')
end