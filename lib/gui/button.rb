class Button
  attr_accessor :data

  def initialize(text, options = {}, &handler)
    @data = options[:data]
    @text = Text.new "[#{text}]", options
    @handler = handler
  end

  def mouse_click(pos)
    if @text.to_rect.contain?(pos)
      @handler.call self
    end
  end

  def draw_on(win)
    win.draw @text
  end
end