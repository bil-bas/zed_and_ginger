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
      @@tool_tip = ToolTip.new
    end

    @@cursor.pos = mouse_pos / user_data.scaling

    self.cursor_shown = options[:cursor_shown]

    @control_under_cursor = nil
    @control_under_cursor_at = nil

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
    unhover_control

    super *args
  end

  public
  def clean_up
    unhover_control

    super
  end

  protected
  def unhover_control
    @control_under_cursor.unhover if @control_under_cursor
    @control_under_cursor = nil
    @control_under_cursor_at = nil
    @@tool_tip.string = ''
  end

  public
  def register
    super

    event_group :gui_mouse do
      on :mouse_left do
        @left_with_cursor_shown = cursor_shown?

        self.cursor_shown = false
        unhover_control
      end

      on :mouse_motion do |pos|
        # Ensure that we ignore events where pos hasn't changed.
        pos = pos / user_data.scaling
        if pos != @@cursor.pos
          @@cursor.pos = pos
          @mouse_moved_at = Time.now
          @@tool_tip.string = ''
        end
      end

      on :mouse_hover do |control|
        @control_under_cursor = control
        @mouse_moved_at = Time.now
      end

      on :mouse_unhover do |control|
        @mouse_moved_at = Time.now
        unhover_control
      end
    end

    on :mouse_entered do
      @mouse_moved_at = Time.now
      self.cursor_shown = true if @left_with_cursor_shown
    end
  end

  def update
    super

    if @control_under_cursor and (Time.now - @mouse_moved_at > ToolTip::DELAY) and @control_under_cursor.tip
      @@tool_tip.string = @control_under_cursor.tip
      @@tool_tip.position = @@cursor.pos + [0, @@cursor.image.height / 2.0]
    end
  end

  public
  def render(win)
    super

    @@tool_tip.draw_on win if @@tool_tip.shown?
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
    gui_controls << Button.new(t.button.back.string, at: [TITLE_X, BOTTOM_BUTTONS_Y], size: SUB_HEADING_SIZE) do
      pop_scene
    end
  end
end
