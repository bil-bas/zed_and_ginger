require_relative 'gui_scene'
require_relative '../starscape'
require_relative '../preloader'

module Ginger
  EYE_COLOR = Color.new(79, 207, 108)
end
module Zed
  EYE_COLOR = Color.new(255, 0, 255)
  SKIN_COLORS = [Color.new(30, 0, 30), Color.new(40, 0, 40), Color.new(50, 0, 50), Color.new(70, 0, 70)]
end

class MainMenu < GuiScene
  TITLE_COLOR = Color.new(255, 150, 0)
  BUTTON_COLOR = Color.white
  TEXT_COLOR = Color.new(200, 200, 200)
  DISABLED_COLOR = Color.new(100, 100, 100)

  BUTTON_SPACING = 1
  
  TITLE_FONT_SIZE = 16
  PLAY_FONT_SIZE = 7
  LEVEL_FONT_SIZE = 5.5
  FONT_SIZE = 4.5
  MUTATOR_FONT_SIZE = 3.5
  SMALL_FONT_SIZE = 3.5
  LEVELS_Y = 16

  MARGIN = 2
  width = GAME_RESOLUTION.width
  CENTER = (width - 1) / 2
  LEFT_EDGE = MARGIN
  RIGHT_EDGE = width - MARGIN
  TOP_EDGE = MARGIN * 1.5  # (since text is tall)

  FLOOR_TILES = [
      "--------",
      "--------",
  ]

  public
  def setup
    started_at = Time.now

    super()

    self.background ||= Starscape.new
    create_floor
    create_cats

    gui_controls << ShadowText.new(t.label.title, at: [CENTER, 0], size: TITLE_FONT_SIZE, color: TITLE_COLOR,
      auto_center: [0.5, 0])

    y = LEVELS_Y
    gui_controls << ShadowText.new(t.label.level, at: [LEFT_EDGE, y], size: LEVEL_FONT_SIZE, color: TEXT_COLOR)

    # Get the numbers of all the levels defined.
    @level_numbers = Level::LEVEL_NUMBERS - [UserData::DEV_LEVEL]

    create_level_buttons # Creates the list of level buttons based on whether hardcore is toggled.

    if DEVELOPMENT_MODE
      gui_controls << Button.new("#{UserData::DEV_LEVEL}-dev", at: [30, LEVELS_Y + 8], size: LEVEL_FONT_SIZE) do
        start_level UserData::DEV_LEVEL
      end
    end

    y += gui_controls.last.height + BUTTON_SPACING * 2

    # Mutators on left hand margin.
    @hardcore = CheckButton.new(t.button.hardcore.string, at: [LEFT_EDGE, y], size: MUTATOR_FONT_SIZE,
                                 checked: user_data.hardcore?,
                                 tip: t.button.hardcore.tip) do |button, checked|
      user_data.hardcore = checked
      create_level_buttons
    end

    y += @hardcore.height + BUTTON_SPACING

    @inversion = CheckButton.new(t.button.inversion.string, at: [LEFT_EDGE, y], size: MUTATOR_FONT_SIZE,
                                 checked: user_data.inversion?,
                                 tip: t.button.inversion.tip) do |button, checked|
      user_data.inversion = checked
      create_level_buttons
    end

    self.gui_controls += [@hardcore, @inversion]

    # Buttons in a column on the right hand side of the screen.
    y = 18
    play_tip = lambda {
      modes = if user_data.hardcore?
         if user_data.inversion?
           " <HC INV>"
         else
           " <HC>"
         end
      elsif user_data.inversion?
         " <INV>"
      else
         ""
      end

      t.button.play.tip @level_buttons.value, t.players[@cat_selection.value], modes
    }
    gui_controls << Button.new(t.button.play.string, at: [RIGHT_EDGE, y], size: PLAY_FONT_SIZE, auto_center: [1, 0],
                               tip: play_tip) do
      start_level @level_buttons.value
    end

    y += gui_controls.last.height + BUTTON_SPACING * 2

    # Replay the intro.
    gui_controls << Button.new(t.button.intro.string, at: [RIGHT_EDGE, y], size: FONT_SIZE,
                                 auto_center: [1, 0], tip: t.button.intro.tip) do
      play_intro
    end

    y += gui_controls.last.height + BUTTON_SPACING

    # High scores.
    gui_controls << Button.new(t.button.high_scores.string, at: [RIGHT_EDGE, y], size: FONT_SIZE, shortcut: :s,
                                 auto_center: [1, 0], tip: t.button.high_scores.tip) do
      push_scene :high_scores
    end

    y += gui_controls.last.height + BUTTON_SPACING

    # User settings - controls.
    gui_controls << Button.new(t.button.options.string, at: [RIGHT_EDGE, y], size: FONT_SIZE,
                                 auto_center: [1, 0], tip: t.button.options.tip) do
      push_scene :options_multimedia
    end

    y += gui_controls.last.height + BUTTON_SPACING

    # User settings - controls.
    gui_controls << Button.new(t.button.controls.string, at: [RIGHT_EDGE, y], size: FONT_SIZE,
                                 auto_center: [1, 0], tip: t.button.controls.tip) do
      push_scene :options_controls
    end

    y += gui_controls.last.height + BUTTON_SPACING

    gui_controls << Button.new(t.button.quit.string, at: [RIGHT_EDGE, y], size: FONT_SIZE, auto_center: [1, 0],
                               tip: t.button.quit.tip) do
      raise_event :quit
    end

    # Version number (top right).
    gui_controls << ShadowText.new("v#{ZedAndGinger::VERSION}", at: [RIGHT_EDGE, TOP_EDGE],
                                   size: SMALL_FONT_SIZE, color: TEXT_COLOR, auto_center: [1, 1])

    reset_ambient_music_volume
    ambient_music.play if ambient_music.time == 0

    window.icon = image image_path("window_icon.png")

    log.info { "#{self.class} loaded in #{Time.now - started_at}s" }

    # Bit of a fudgy way to prevent the intro being reloaded if we flip fullscreen/window.
    play_intro if user_data.auto_show_intro?

    @@preloader ||= Preloader.new
  end

  def play_intro
    ambient_music.pause
    run_scene :intro_outside, @player_sheets
    user_data.auto_show_intro = false
    ambient_music.play
  end

  protected
  def create_level_buttons
    current_level = user_data.selected_level

    @level_buttons = RadioGroup.new(at: [LEFT_EDGE + 14, LEVELS_Y], default_button_options: { size: LEVEL_FONT_SIZE }) do |value|
      user_data.selected_level = value
    end

    @level_numbers.each do |i|
      @level_buttons.button(i.to_s, i,  enabled: user_data.level_unlocked?(i, mode: user_data.mode), tip: t.button.level.tip(i))
    end

    @level_buttons.select current_level

    add_level_button_events
  end

  def add_level_button_events
    remove_event_group @level_buttons

    @level_buttons.register(self)
  end

  protected
  def create_floor
    @floor_map = FloorMap.new self, FLOOR_TILES, CheckeredFloor
  end

  protected
  def create_cats
    @ginger_image = Image.new image_path("player.png")

    # Animations
    @cat_animations = {}
    @cat_animations[:walking1] = sprite_animation from: Player::WALKING_ANIMATION[0],
                                      to: Player::WALKING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION * 2
    @cat_animations[:walking2] = @cat_animations[:walking1].dup

    @cat_animations[:sitting] = sprite_animation from: Player::SITTING_ANIMATION[0],
                                         to: Player::SITTING_ANIMATION[1],
                                         duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @cat_animations.each_value(&:loop!)

    # Create Zed.
    unless defined? @@zed_image
      @@zed_image = @ginger_image.dup

      @@zed_image.map_with_pos! do |color, x, y|
        if color.alpha < 50
          Color.none
        elsif color == Ginger::EYE_COLOR
          Zed::EYE_COLOR
        else
          column = (x.div 16) % 4 # Some animations are 4-wide.
          x_in_sprite, y_in_sprite = 16 - (x % 16), y % 16
          Zed::SKIN_COLORS[(x_in_sprite + y_in_sprite + column) % Zed::SKIN_COLORS.size]
        end
      end
    end

    @zed = sprite @@zed_image, at: [18, 57]
    @zed.scale = [2, 2]

    # Create Ginger.
    @ginger = sprite @ginger_image, at: [52, 57]
    @ginger.scale = [2, 2]

    @zed.sheet_size = @ginger.sheet_size = [8, 5]
    @zed.origin = @ginger.origin = [@zed.sprite_width / 2, @zed.sprite_height]

    # Buttons to choose to play one or both cats.
    @cat_selection = RadioGroup.new(at: [22, 32], default_button_options: { size: FONT_SIZE }) do |value|
      case value
        when :zed
          @cat_animations[:walking1].start @zed
          @cat_animations[:sitting].start @ginger
          @cat_animations[:walking2].pause

        when :ginger
          @cat_animations[:sitting].start @zed
          @cat_animations[:walking1].start @ginger
          @cat_animations[:walking2].pause

        when :both
          @cat_animations[:walking1].start @zed
          @cat_animations[:walking2].start @ginger
          @cat_animations[:sitting].pause
      end

      user_data.selected_cat = value
    end

    @cat_selection.button(t.button.selected_cat.zed.string, :zed, tip: t.button.selected_cat.zed.tip)
    @cat_selection.button(t.button.selected_cat.both.string, :both, tip: t.button.selected_cat.both.tip)
    @cat_selection.button(t.button.selected_cat.ginger.string, :ginger, tip: t.button.selected_cat.ginger.tip)

    @cat_selection.select user_data.selected_cat

    @player_sheets = {
        zed: @@zed_image,
        ginger: @ginger_image,
    }

    self.gui_controls += [@zed, @ginger, @cat_selection]
  end

  protected
  def start_level(level_number)
    cat = user_data.selected_cat
    player_data = if cat == :both
      @player_sheets
    else
      { cat => @player_sheets[cat] }
    end

    push_scene :level, level_number, player_data, user_data.hardcore?, user_data.inversion?
  end

  public
  def register
    super

    add_level_button_events

    on :focus_gain do
      ambient_music.play
    end

    on :focus_loss do
      ambient_music.pause
    end
  end

  def update
    super

    background.update frame_time

    @cat_animations.each_value(&:update)
    @@preloader.update
  end

  public
  def render(win)
    background.draw_on win

    floor_camera = win.view
    floor_camera.size = GAME_RESOLUTION * user_data.scaling
    floor_camera.zoom_by user_data.scaling * 2
    floor_camera.x = 30.5
    floor_camera.y = -8
    win.with_view floor_camera do
      @floor_map.draw_on win
    end

    @level_buttons.draw_on win

    super(win)
  end
end
