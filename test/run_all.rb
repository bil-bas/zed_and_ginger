require 'win32console'
require 'riot'
require 'riot/rr'

DEVELOPMENT_MODE = true
ROOT_PATH = EXTRACT_PATH = File.expand_path("../../", __FILE__)
$create_window = false # Prevent the game from actually opening a window.

require_relative '../lib/main'

Dir["#{File.dirname(__FILE__)}/**/*_test.rb"].each do |filename|
  load filename
end
