require_relative "game_scene"

class GuiScene < GameScene
  # List of controls, automatically drawn in order.
  attr_reader :gui_controls

  def setup
    super

    cursor_image = image(image_path("cursor.png"))
    @cursor = sprite cursor_image, scale: [0.5, 0.5], origin: [0, 0]
    @cursor_shown = true
    @gui_controls = []
  end

  def register
    super

    on :mouse_left do
      @cursor_shown = false
    end

    on :mouse_entered do
      @cursor_shown = true
    end

    on :mouse_motion do |pos|
      @cursor.pos = pos / window.scaling
    end
  end

  def render(win)
    win.with_view win.default_view do
      @gui_controls.each {|c| c.draw_on win }
    end

    win.draw @cursor if @cursor_shown
  end
end
