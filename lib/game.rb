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

%w[enter_name level pause pick_level ready_set_go teleporting].each do |filename|
  require_relative "scenes/#{filename}"
end

%w[progress_bar shadow_text timer].each do |filename|
  require_relative "gui/#{filename}"
end

def media_path(type, resource)
 File.expand_path File.join(File.dirname(__FILE__), "../media/#{type}", resource)
end

def image_path(resource); media_path('images', resource); end
def sound_path(resource); media_path('sounds', resource); end
def font_path(resource); media_path('fonts', resource); end
def music_path(resource); media_path('music', resource); end

def shader_path(resource); File.expand_path File.join(File.dirname(__FILE__), "../lib/shaders", resource); end

FONT_NAME = font_path("MonteCarloFixed12.ttf") # http://www.bok.net/MonteCarlo/
SCENE_CLASSES = [EnterName, Level, Pause, PickLevel, ReadySetGo, Teleporting]

class Ray::Window
  attr_accessor :scaling
end

DEFAULT_SCALING = 8
GAME_RESOLUTION = Vector2[96, 60]

Ray.game "Zed and Ginger (WASD or ARROWS to move; SPACE to jump)", size: GAME_RESOLUTION * DEFAULT_SCALING do
  register do
    on :quit, &method(:exit!)
  end

  window.scaling = window.size.width / GAME_RESOLUTION.width

  SCENE_CLASSES.each {|s| s.bind(self) }
  scenes << :pick_level unless defined? Ocra
end