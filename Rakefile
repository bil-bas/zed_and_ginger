Config = RbConfig if RUBY_VERSION > '1.9.2' # Hack to allow stuff that isn't compatible with 1.9.3 to work.

require 'rake/clean'

APP = "zed_and_ginger"
APP_READABLE = "Zed and Ginger"
require_relative "lib/version"
RELEASE_VERSION = ZedAndGinger::VERSION

OSX_GEMS = [] # Ray can't be released as OSX.

# My scripts which help me package games.
require_relative "../release_packager/lib/release_packager"


CLEAN.include("*.log")
CLOBBER.include("doc/**/*")


desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

desc "Run all our tests"
task :test do
  begin
    ruby File.expand_path("test/run_all.rb", File.dirname(__FILE__))
  rescue
    exit 1
  end
end


