require 'yaml'
require 'forwardable'
require 'pry' if DEVELOPMENT_MODE

require_relative "ray_ext"

%w[level pick_level].each do |filename|
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

def shader_path(resource); File.expand_path File.join(File.dirname(__FILE__), "../lib/shaders", resource); end

FONT_NAME = font_path("pixelated.ttf")
SCENE_CLASSES = [Level, PickLevel]

Ray.game "Zed and Ginger (WASD or ARROWS to move; SPACE to jump)", size: [768, 480] do
  register do
    on :quit, &method(:exit!)
  end

  SCENE_CLASSES.each {|s| s.bind(self) }
  scenes << :pick_level unless defined? Ocra
end