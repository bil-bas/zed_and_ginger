begin
  # This doesn't work for me, so I needed to use Ansicon instead.
  if RUBY_PLATFORM =~ /mswin32|mingw32/
    require 'win32console'
    require 'Win32/Console/ANSI'
    include Win32::Console::ANSI
  end
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end

require 'riot'
require 'riot/rr'

DEVELOPMENT_MODE = true
ROOT_PATH = EXTRACT_PATH = File.expand_path("../../", __FILE__)
$create_game_with_scene = nil # Prevent the game from actually opening a window.

require_relative '../lib/main'

Log.level = :WARNING # Don't pring out junk.

Dir["#{File.dirname(__FILE__)}/**/*_test.rb"].each do |filename|
  require filename
end
