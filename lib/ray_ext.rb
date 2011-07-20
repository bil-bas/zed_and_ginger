require 'ray'

%w[drawable matrix].each do |file_name|
  require_relative "ray_ext/#{file_name}"
end

include Ray
