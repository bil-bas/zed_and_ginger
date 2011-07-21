class PickLevel < Scene
  def setup
    @levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @levels.map! {|file| File.basename(file).to_i }.sort

    @items = []
    @items << ShadowText.new("Pick a level", at: [40, 10], font: FONT_NAME, size: 64, shadow_offset: [4, 4])
    @levels.each_with_index do |level, i|
      @items << ShadowText.new(level.to_s, at: [60 + i * 60, 110], font: FONT_NAME, size: 32)
    end

    @cat = sprite image_path("player.png"), at: [100, 200]
    @cat.sheet_size = [8, 5]
    @cat_animation = sprite_animation from: Player::SITTING_ANIMATION[0],
                                      to: Player::SITTING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @cat_animation.loop!
    @cat_animation.start(@cat)
    @cat.scale = [16, 16]

    window.hide_cursor
  end

  def register
    on :text_entered do |char|
      if char.to_i > 0
        push_scene :level, char.to_i
      end
    end

    always do
      @cat_animation.update
    end

    render do |win|
      win.clear Color.new(0, 100, 50)
      @items.each {|item| item.draw_on win }

      win.draw @cat
    end
  end
end
