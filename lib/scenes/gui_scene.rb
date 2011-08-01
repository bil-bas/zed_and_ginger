require_relative "game_scene"

# Just like a GameScene, but with a cursor.
class GuiScene < GameScene
  def cursor_shown?; @cursor_shown; end

  def setup(options = {})
    options = {
        cursor_shown: true,
    }.merge! options

    super()

    unless defined? @@cursor
      cursor_image = image(image_path("cursor.png"))
      @@cursor = sprite cursor_image, scale: [0.5, 0.5]
    end

    @@cursor.pos = mouse_pos / user_data.scaling

    self.cursor_shown = options[:cursor_shown]

    @control_under_cursor = nil

    @left_with_cursor_shown = cursor_shown?
  end

  def cursor_shown=(shown)
    @cursor_shown = shown

    if @cursor_shown
      enable_event_group :gui_mouse
    else
      disable_event_group :gui_mouse
    end

    @cursor_shown
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

    event_group :gui_mouse do
      on :mouse_left do
        @left_with_cursor_shown = cursor_shown?
        self.cursor_shown = false
      end

      on :mouse_motion do |pos|
        @@cursor.pos = pos / user_data.scaling
      end

      on :mouse_hover do |control|
        @control_under_cursor = control
      end

      on :mouse_unhover do |control|
        @control_under_cursor = nil
      end
    end

    on :mouse_entered do
      self.cursor_shown = true if @left_with_cursor_shown
    end
  end

  def render(win)
    super

    win.draw @@cursor if cursor_shown?
  end
end
