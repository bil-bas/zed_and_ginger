require 'ray'

def media_path(type, resource)
 File.expand_path File.join(File.dirname(__FILE__), "../media/#{type}", resource)
end

def image_path(resource); media_path('images', resource); end
def sound_path(resource); media_path('sounds', resource); end
def font_path(resource); media_path('fonts', resource); end
def music_path(resource); media_path('music', resource); end

module Ray
  class Window
    def scaled_size
      size / $scaling
    end
  end
end

def shader_path(resource); File.expand_path File.join(File.dirname(__FILE__), "../lib/shaders", resource); end

%w[animation drawable font matrix rect].each do |file_name|
  require_relative "ray_ext/#{file_name}"
end

include Ray
