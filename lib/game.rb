require 'yaml'
require 'forwardable'

begin
  require 'bundler/setup' unless defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

rescue LoadError
  $stderr.puts "Bundler gem not installed. To install:\n  gem install bundler"
  exit
rescue Exception
  $stderr.puts "Gem dependencies not met. To install:\n  bundle install"
  exit
end

require_relative "ray_ext"
require_relative "version"
require_relative "user_data"

%w[enter_name game_over level pause pick_level ready_set_go teleporting].each do |filename|
  require_relative "scenes/#{filename}"
end

%w[button progress_bar shadow_text timer].each do |filename|
  require_relative "gui/#{filename}"
end

%w[hash].each do |filename|
  require_relative "standard_ext/#{filename}"
end

SCENE_CLASSES = [EnterName, GameOver, Level, Pause, PickLevel, ReadySetGo, Teleporting]

GAME_RESOLUTION = Vector2[96, 60]

Window.user_data = UserData.new
window_size = GAME_RESOLUTION * Window.scaling

Ray.game "Zed and Ginger (WASD to move; SPACE to jump, P to pause)", size: window_size do
  register do
    on :quit do
      Kernel.exit
    end

    on :key_press, key(:f12) do
      path = File.join(ROOT_PATH, 'screenshots')
      FileUtils.mkdir_p path
      files = Dir[File.join(path, "screenshot_*.*")]
      last_number = files.map {|f| f =~ /(\d+)\.bmp$/; $1.to_i }.sort.last || 0
      window.to_image.write(File.join(path, "screenshot_#{(last_number + 1).to_s.rjust(3, '0')}.bmp"))
    end
  end

  window_view = window.default_view
  window_view.zoom_by window.scaling
  window_view.center = window_view.size / 2
  window.view = window_view

  SCENE_CLASSES.each {|s| s.bind(self) }
  scenes << :pick_level unless defined? Ocra
end