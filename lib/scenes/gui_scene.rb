require_relative "game_scene"

# Just like a GameScene, but with a cursor.
class GuiScene < GameScene
  LABEL_COLOR = Color.new(200, 200, 200)

  LINE_SPACING = 0.3
  HEADING_SIZE = 6
  SUB_HEADING_SIZE = 4.5
  ITEM_SIZE = 4

  TITLE_X = 4
  LABEL_X = 6
  BUTTON_X = 35
  BOTTOM_BUTTONS_Y = 55

  def cursor_shown?; @cursor_shown; end

  public
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

  protected
  def cursor_shown=(shown)
    @cursor_shown = shown

    if @cursor_shown
      enable_event_group :gui_mouse
    else
      disable_event_group :gui_mouse
    end

    @cursor_shown
  end

  protected
  def run_scene(*args)

    # Ensure that hovering is removed entering a dialog.
    if @control_under_cursor
      @control_under_cursor.unhover
      @control_under_cursor = nil
    end

    super *args
  end

  public
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

  public
  def render(win)
    super

    win.draw @@cursor if cursor_shown?
  end

  protected
  def sub_heading(y, text)
    sub_heading = ShadowText.new(text, at: [LABEL_X, y], size: SUB_HEADING_SIZE)

    # Create a semi-transparent background behind the sub-title.
    rect = sub_heading.rect
    rect.x -= LABEL_X - TITLE_X
    rect.width = GAME_RESOLUTION.width - (rect.x * 2)
    gui_controls << Polygon.rectangle(rect)
    gui_controls.last.color = Color.new(255, 255, 255, 50)

    gui_controls << sub_heading
    y += gui_controls.last.height + LINE_SPACING
    y
  end

  protected
  def back_button
    gui_controls << Button.new("Back", at: [TITLE_X, BOTTOM_BUTTONS_Y], size: SUB_HEADING_SIZE) do
      pop_scene
    end
  end
end
