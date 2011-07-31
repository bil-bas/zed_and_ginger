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

require_relative 'ray_ext'

GAME_RESOLUTION = Vector2[96, 60] # Resolution of tiles, at least.

require_files('./', %w[log my_game user_data version])
require_files('mixins', %w[has_status registers])
require_files('scenes', %w[confirm enter_control enter_name game_over level options_controls pause main_menu ready_set_go teleporting])
require_files('gui', %w[button check_button fps_monitor progress_bar score_card shadow_text timer])
require_files('standard_ext', %w[hash])


if defined? RubyProf
  RubyProf.start
  RubyProf.pause
  Log.log.debug { "Profiling started and paused" }
end

CLASSES_WITH_SHADERS = [SlowFloor, SlowSplat, Teleporter, Teleporting]
SCENE_CLASSES = [Confirm, EnterControl, EnterName, GameOver, Level, OptionsControls, Pause, MainMenu, ReadySetGo, Teleporting]


def create_game
  Window.user_data = UserData.new

  options = if Window.user_data.fullscreen?
    { size: Ray.screen_size, fullscreen: true }
  else
    { size: GAME_RESOLUTION * Window.scaling }
  end

  MyGame.new("Zed and Ginger", options).run
end

$create_window = true
while $create_window
  $create_window = false

  begin
    create_game

  rescue => exception
    message = <<-END
The game suffered from a fatal error and had to go and die in a corner.
The full error report has been written to zed_and_ginger.log

#{exception.class}: #{exception.message}

#{exception.backtrace.join("\n")}"
END
    Log.log.error { message }

    Ray.game "Zed and Ginger error!", size: [640, 480] do
      scene :scene do
        y = 0
        @lines = message.split("\n").map do |line|
          text = Text.new(line, at: [0, y], size: 16)
          y += text.size * 0.8 / Window.user_data.scaling
          text
        end

        def render(win)
          @lines.each {|line| win.draw line }
        end
      end

      scenes << :scene
    end
  end
end