require_relative "game_scene"

# Just like a GameScene, but with a cursor.
class GuiScene < GameScene
  def setup(options = {})
    options = {
        enable_cursor: true,
    }.merge! options

    super()

    unless defined? @@cursor
      cursor_image = image(image_path("cursor.png"))
      @@cursor = sprite cursor_image, scale: [0.5, 0.5]
      @@cursor.pos = mouse_pos / window.scaling
    end

    @cursor_shown = options[:enable_cursor]

    @control_under_cursor = nil
  end

  def run_scene(*args)

    # Ensure that hovering is removed entering a dialog.
    if @control_under_cursor
      @control_under_cursor.unhover
      @control_under_cursor = nil
    end

    super *args
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
        @@cursor.pos = pos / window.scaling
      end

      on :mouse_hover do |control|
        @control_under_cursor = control
      end

      on :mouse_unhover do |control|
        @control_under_cursor = nil
      end
    end
  end

  def render(win)
    super

    win.draw @@cursor if @cursor_shown
  end
end
