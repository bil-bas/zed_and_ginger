require 'fiber'

# Load all images and sounds before they are needed.
# This makes barely any difference in this game, but does reduce level loading by a bit and
# avoids potential file-system stutters!
class Preloader
  include Helper
  include Log

  def initialize
    @fiber = Fiber.new do
      started_at = Time.now

      # Fonts.
      font_files = Dir[File.join(font_path(""), "**/*.ttf")]
      log.info { "Preloading #{font_files.size} fonts" }
      Fiber.yield

      font_files.each do |font_file|
        # Load the font of the size we want to use.
        text "!", font: font_file, size: Level::FONT_SIZE
        text "!", font: font_file, size: MessageScreen::FONT_SIZE
        Fiber.yield
      end

      # Sounds.
      sound_files = Dir[File.join(sound_path(""), "**/*.ogg")]
      log.info { "Preloading #{sound_files.size} sounds" }
      Fiber.yield

      sound_files.each do |sound_file|
        SoundBufferSet[sound_file]
        Fiber.yield
      end

      # Images.
      image_files = Dir[File.join(image_path(""), "**/*.png")]
      log.info { "Preloading #{image_files.size} images" }
      Fiber.yield

      image_files.each do |image_file|
        ImageSet[image_file]
        Fiber.yield
      end

      # Shaders take about 4ms each to create.
      log.info { "Preloading #{CLASSES_WITH_SHADERS.size} shaders" }
      CLASSES_WITH_SHADERS.each do |class_with_shader|
        class_with_shader.shader
        Fiber.yield
      end

      log.info { "Preload complete in #{Time.now - started_at}s" }
    end
  end

  def update
    @fiber.resume if @fiber.alive?
  end
end
