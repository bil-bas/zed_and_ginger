class PickLevel < Scene
  BACKGROUND_COLOR = Color.new(0, 100, 50)

  TUTORIAL_LETTER = 'T'

  def setup
    @levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @levels.map! {|file| File.basename(file).to_i }.sort

    @heading = ShadowText.new("Zed and Ginger", at: [5, 2.5], size: 10)
    @sub_heading = ShadowText.new("Pick a level", at: [5, 12.5], size: 6)

    @level_buttons = []
    @levels.each_with_index do |level, i|
      name = level == 0 ? '[T]' : "[#{level}]"
      @level_buttons << Text.new(name, at: [7.5 + i * 8, 21], size: 6)
    end

    @cat = sprite image_path("player.png"), at: [12.5, 25]
    @cat.sheet_size = [8, 5]
    @cat_animation = sprite_animation from: Player::SITTING_ANIMATION[0],
                                      to: Player::SITTING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @cat_animation.loop!
    @cat_animation.start(@cat)
    @cat.scale = [2, 2]

    window.show_cursor

    @@ambient_music ||= music music_path("Space_Cat_Ambient.ogg")
    @@ambient_music.looping = true
    @@ambient_music.play
    @@ambient_music.volume = 70
  end

  def clean_up
    @@ambient_music.pause
  end

  def register
    # Allow key 1, 2, 3 to start level.
    on :text_entered do |char|
      char = Ray::TextHelper.convert(char).upcase
      char = '0' if char == TUTORIAL_LETTER or char == '`'
      if ('0'..'2').include? char
        push_scene :level, char.to_i
      end
    end

    window.icon = image image_path("window_icon.png")

    # Allow mouse click on numeral to start level.
    on :mouse_press do |button, pos|
      if button == :left
        @level_buttons.each_with_index do |button, i|
          if button.to_rect.contain? pos
            push_scene :level, @levels[i]
          end
        end
      end
    end

    always do
      @cat_animation.update
    end
  end

  def render(win)
    win.clear BACKGROUND_COLOR

    win.with_view win.default_view do
      @heading.draw_on win
      @sub_heading.draw_on win
      @level_buttons.each {|item| win.draw item }
    end

    win.draw @cat
  end
end
