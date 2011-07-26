require_relative "game_scene"

# Just like a GameScene, but with a cursor.
class GuiScene < GameScene
  def setup(options = {})
    options = {
        enable_cursor: true,
    }.merge! options

    super()

    cursor_image = image(image_path("cursor.png"))
    @cursor = sprite cursor_image, scale: [0.5, 0.5], origin: [0, 0]

    @cursor_shown = options[:enable_cursor]
  end

  def register
    super

    if @cursor_shown
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
  end

  def render(win)
    super

    win.draw @cursor if @cursor_shown
  end
end
