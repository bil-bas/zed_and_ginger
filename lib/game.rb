require 'ray'
include Ray
require 'forwardable'

require_relative 'scenes/level'

def image_path(resource)
  File.expand_path File.join(File.dirname(__FILE__), '../media/images', resource)
end

Ray.game "Fred and Ginger" do
  register do
    on :quit, &method(:exit!)
    on :key_press, key(:escape), &method(:exit!)
  end
  
  scene_classes = [Level]
  scene_classes.each {|s| s.bind(self) }
  scenes << :level
end