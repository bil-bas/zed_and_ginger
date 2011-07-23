class PickLevel < Scene
  BACKGROUND_COLOR = Color.new(0, 100, 50)

  def setup
    @levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @levels.map! {|file| File.basename(file).to_i }.sort

    @heading = ShadowText.new("Pick a level", at: [40, 10], font: FONT_NAME, size: 80, shadow_offset: [4, 4])

    @level_buttons = []
    @levels.each_with_index do |level, i|
      @level_buttons << Text.new(level.to_s, at: [60 + i * 60, 110], font: FONT_NAME, size: 50)
    end

    @cat = sprite image_path("player.png"), at: [100, 200]
    @cat.sheet_size = [8, 5]
    @cat_animation = sprite_animation from: Player::SITTING_ANIMATION[0],
                                      to: Player::SITTING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @cat_animation.loop!
    @cat_animation.start(@cat)
    @cat.scale = [16, 16]

    window.show_cursor
  end

  def register
    # Allow key 1, 2, 3 to start level.
    on :text_entered do |char|
      if char.to_i > 0
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

    render do |win|
      win.clear BACKGROUND_COLOR

      @heading.draw_on win
      @level_buttons.each {|item| win.draw item }

      win.draw @cat
    end
  end
end
