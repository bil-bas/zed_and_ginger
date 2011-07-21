class PickLevel < Scene
  def setup
    @levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @levels.map! {|file| File.basename(file).to_i }.sort

    @items = []
    @items << ShadowText.new("Pick a level", at: [40, 10], font: FONT_NAME, size: 64)
    @levels.each_with_index do |level, i|
      @items << ShadowText.new(level.to_s, at: [60 + i * 60, 110], font: FONT_NAME, size: 32)
    end

    window.hide_cursor
  end

  def register
    on :text_entered do |char|
      if char.to_i > 0
        push_scene :level, char.to_i
      end
    end

    render do |win|
      @items.each {|item| item.draw_on win }
    end
  end
end
