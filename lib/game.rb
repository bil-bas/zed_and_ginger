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

def require_files(dir, files)
  files.each do |filename|
    require_relative File.join(dir, filename)
  end
end

require_files('./', %w[log ray_ext user_data version])
require_files('statuses', %w[invulnerable])
require_files('mixins', %w[has_status])
require_files('scenes', %w[enter_name game_over level pause pick_level ready_set_go teleporting])
require_files('gui', %w[button progress_bar shadow_text timer])
require_files('standard_ext', %w[hash])

SCENE_CLASSES = [EnterName, GameOver, Level, Pause, PickLevel, ReadySetGo, Teleporting]

GAME_RESOLUTION = Vector2[96, 60]

Window.user_data = UserData.new
window_size = GAME_RESOLUTION * Window.scaling

class Ray::Game
  SCREEN_SHOT_EXTENSION = 'tga'
end

Ray.game "Zed and Ginger (WASD to move; SPACE to jump, P to pause)", size: window_size do
  register do
    on :quit do
      Kernel.exit
    end

    on :key_press, key(window.user_data.control(:screenshot)) do
      path = File.join(ROOT_PATH, 'screenshots')
      FileUtils.mkdir_p path
      files = Dir[File.join(path, "screenshot_*.#{SCREEN_SHOT_EXTENSION}")]
      last_number = files.map {|f| f =~ /(\d+)\.#{SCREEN_SHOT_EXTENSION}$/; $1.to_i }.sort.last || 0
      window.to_image.write(File.join(path, "screenshot_#{(last_number + 1).to_s.rjust(3, '0')}.#{SCREEN_SHOT_EXTENSION}"))
    end
  end

  window_view = window.default_view
  window_view.zoom_by window.scaling
  window_view.center = window_view.size / 2
  window.view = window_view

  SCENE_CLASSES.each {|s| s.bind(self) }
  scenes << :pick_level unless defined? Ocra
end