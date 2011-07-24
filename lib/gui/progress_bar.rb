class ProgressBar
  def initialize(rect)
    @background = Polygon.rectangle(rect)
    @background.outline = Color.black
    @background.outlined = true
    @background.outline_width /= $scaling

    @progress = Polygon.rectangle(rect)
    @progress.color = Color.new(50, 50, 200)
  end

  def progress; @progress.scale_x; end
  def progress=(progress); @progress.scale_x = progress; end

  def draw_on(window)
    window.draw @background
    window.draw @progress
  end
end
