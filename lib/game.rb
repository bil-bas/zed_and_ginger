DEVELOPMENT_MODE = ARGV.include? "--dev"

require 'ray'
require 'pry' if DEVELOPMENT_MODE

include Ray
require 'forwardable'

require_relative 'scenes/level'
require_relative 'gui/shadow_text'
require_relative 'gui/progress_bar'
require_relative 'gui/timer'

def media_path(type, resource)
 File.expand_path File.join(File.dirname(__FILE__), "../media/#{type}", resource)
end

def image_path(resource); media_path('images', resource); end
def sound_path(resource); media_path('sounds', resource); end
def font_path(resource); media_path('fonts', resource); end

FONT_NAME = font_path("pixelated.ttf")

Ray.game "Zed and Ginger", size: [768, 480] do
  register do
    on :quit, &method(:exit!)
    on :key_press, key(:escape), &method(:exit!)
  end
  
  scene_classes = [Level]
  scene_classes.each {|s| s.bind(self) }
  scenes << :level
end