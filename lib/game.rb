require 'yaml'
require 'forwardable'
require 'fileutils'

begin
  require 'bundler/setup' unless DEVELOPMENT_MODE or defined?(OSX_EXECUTABLE) or ENV['OCRA_EXECUTABLE']

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
require_files('mixins', %w[has_status])
require_files('scenes', %w[confirm enter_control enter_name game_over level options_controls pause main_menu ready_set_go teleporting])
require_files('gui', %w[button progress_bar shadow_text timer])
require_files('standard_ext', %w[hash])

GAME_RESOLUTION = Vector2[96, 60] # Resolution of tiles, at least.

class Ray::Game
  SCENE_CLASSES = [Confirm, EnterControl, EnterName, GameOver, Level, OptionsControls, Pause, MainMenu, ReadySetGo, Teleporting]

  SCREEN_SHOT_EXTENSION = 'tga'
end

$create_window = true
while $create_window
  $create_window = false

  Window.user_data = UserData.new

  options = if Window.user_data.fullscreen?
    { size: Ray.screen_size, fullscreen: true }
  else
    { size: GAME_RESOLUTION * Window.scaling }
  end

  Ray.game "Zed and Ginger (WASD to move; SPACE to jump, P to pause)", options do
    register do
      on :quit do
        Kernel.exit
      end

      on :key_press, *key_or_code(window.user_data.control(:screenshot)) do
        path = File.join(ROOT_PATH, 'screenshots')
        FileUtils.mkdir_p path
        files = Dir[File.join(path, "screenshot_*.#{SCREEN_SHOT_EXTENSION}")]
        last_number = files.map {|f| f =~ /(\d+)\.#{SCREEN_SHOT_EXTENSION}$/; $1.to_i }.sort.last || 0
        window.to_image.write(File.join(path, "screenshot_#{(last_number + 1).to_s.rjust(3, '0')}.#{SCREEN_SHOT_EXTENSION}"))
      end
    end

    window.hide_cursor

    window_view = window.default_view
    window_view.zoom_by window.scaling
    window_view.center = window_view.size / 2
    window.view = window_view

    SCENE_CLASSES.each {|s| s.bind(self) }
    scenes << :main_menu unless defined? Ocra
  end
end