# Load all images and sounds before they are needed.
# This makes barely any difference in this game, but does reduce level loading by a bit and
# avoids potential file-system stutters!
class Preloader
  include Helper
  include Log

  def initialize
    @font_files = Dir[File.join(font_path(""), "**/*.ttf")]
    @sound_files = Dir[File.join(sound_path(""), "**/*.ogg")]
    @image_files = Dir[File.join(image_path(""), "**/*.png")]
    @shader_classes = CLASSES_WITH_SHADERS.dup
    @complete = false
    log.info { "Preload started." }
  end

  def update
    return if @complete

    if @font_files.any?
      font_file = @font_files.pop
      text "!", font: font_file, size: Level::FONT_SIZE
      text "!", font: font_file, size: MessageScreen::FONT_SIZE
      return
    end

    if @sound_files.any?
      SoundBufferSet[@sound_files.pop]
      return
    end

    if @image_files.any?
      ImageSet[@image_files.pop]
      return
    end

    if @shader_classes.any?
      @shader_classes.pop.shader
      return
    end

    @complete = true

    log.info { "Preload complete." }
  end
end
