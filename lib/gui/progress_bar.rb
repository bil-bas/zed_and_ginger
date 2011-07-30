class ProgressBar
  def initialize(rect)
    @background = Polygon.rectangle(rect)
    @background.outline = Color.black
    @background.outlined = true
    @background.outline_width /= Window.user_data.scaling

    @rect = rect
    @progress = 0
  end

  def progress; @progress; end
  def progress=(progress); @progress = progress; end

  def draw_on(window)
    window.draw @background

    current_rect = @rect.dup
    current_rect.width *= @progress
    window.draw Polygon.rectangle(current_rect, Color.new(50, 50, 200))
  end
end
