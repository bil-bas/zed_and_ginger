class ProgressBar
  def initialize(rect)
    @background = Polygon.rectangle(rect)
    @background.outline = Color.black
    @background.outlined = true
    @background.outline_width /= Window.user_data.scaling

    pos = rect.pos
    rect.x, rect.y = [0, 0]
    @progress = Polygon.rectangle(rect, Color.new(50, 50, 200))
    @progress.pos = *pos
  end

  def progress; @progress; end
  def progress=(progress); @progress.scale_x = progress; end

  def draw_on(window)
    window.draw @background
    window.draw @progress
  end
end
