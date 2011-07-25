require 'ray'


def media_path(type, resource)
 File.expand_path File.join(EXTRACT_PATH, 'media', type, resource)
end

def image_path(resource); media_path('images', resource); end
def sound_path(resource); media_path('sounds', resource); end
def font_path(resource); media_path('fonts', resource); end
def music_path(resource); media_path('music', resource); end

def shader_path(resource); File.expand_path File.join(EXTRACT_PATH, 'lib/shaders', resource); end

%w[animation drawable font matrix rect text window].each do |file_name|
  require_relative "ray_ext/#{file_name}"
end

# Reads in a shader file, doing replacements for all #include statements.
# Returns a string, so StringIO it up.
def read_shader(file_name)
  shader = File.read shader_path(file_name)
  shader.gsub!(/^#include "(.*?)"/) { "\n\n#{read_shader($1)}\n\n" }
  shader
end

include Ray
