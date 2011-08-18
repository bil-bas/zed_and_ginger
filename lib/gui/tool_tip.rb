class ToolTip
  include Registers
  TEXT_COLOR = Color.white
  BACKGROUND_COLOR = Color.new(0, 0, 150)

  def shown?; not @text.string.empty?; end

  def initialize(scene, options = {})
    options = {
        font_size: 3.5,
        text_color: TEXT_COLOR,
        background_color: BACKGROUND_COLOR,
    }.merge! options

    super(scene)

    @text = Text.new '', size: options[:font_size], color: options[:text_color]
    @background = Polygon.rectangle(Rect.new(0, 0, 1, 1), options[:background_color])
  end

  def position=(position)
    position = position.to_vector2
    position.x = [position.x, GAME_RESOLUTION.width - @background.scale_x].min
    position.y = [position.y, GAME_RESOLUTION.height - @background.scale_y].min
    @text.position = position + [1, -0.25]
    @background.position = position
  end

  def string=(string)
    @text.string = string.to_s
    @background.scale = @text.rect.size + [2, 0.5]
  end

  def draw_on(win)
    win.draw @background
    win.draw @text
  end
end
