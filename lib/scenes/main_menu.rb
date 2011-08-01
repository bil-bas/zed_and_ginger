require_relative 'gui_scene'
require_relative '../starscape'
require_relative '../preloader'

module Ginger
  EYE_COLOR = Color.new(79, 207, 108)
end
module Zed
  EYE_COLOR = Color.new(255, 0, 255)
  SKIN_COLORS = [Color.new(70, 0, 70), Color.new(50, 0, 50), Color.new(40, 0, 40), Color.new(30, 0, 30)]
end

class MainMenu < GuiScene
  TITLE_COLOR = Color.new(255, 150, 0)
  BUTTON_COLOR = Color.white
  TEXT_COLOR = Color.new(200, 200, 200)
  DISABLED_COLOR = Color.new(100, 100, 100)

  BUTTON_SPACING = 1
  
  TITLE_FONT_SIZE = 16
  LEVEL_FONT_SIZE = 5.5
  FONT_SIZE = 4.5
  MUTATOR_FONT_SIZE = 3.5
  SMALL_FONT_SIZE = 3.5
  LEVELS_Y = 14

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

    @@preloader ||= Preloader.new


    gui_controls << ShadowText.new("Zed and Ginger", at: [CENTER, 0], size: TITLE_FONT_SIZE, color: TITLE_COLOR,
      auto_center: [0.5, 0])

    y = LEVELS_Y
    gui_controls << ShadowText.new("Level: ", at: [LEFT_EDGE, y], size: LEVEL_FONT_SIZE, color: TEXT_COLOR)

    # Get the numbers of all the levels defined.
    level_files = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @level_numbers = level_files.map {|file| File.basename(file).to_i }.sort
    @level_numbers -= [UserData::DEV_LEVEL]

    create_level_buttons # Creates the list of level buttons based on whether hardcore is toggled.

    y += gui_controls.last.height + BUTTON_SPACING * 2

    # Mutators on left hand margin.
    @hardcore = CheckButton.new("Hardcore", self, at: [LEFT_EDGE, y], size: MUTATOR_FONT_SIZE,
                                 checked: user_data.hardcore?) do |button, checked|
      user_data.hardcore = checked
      create_level_buttons
    end

    y += @hardcore.height + BUTTON_SPACING

    @inversion = CheckButton.new("Inversion", self, at: [LEFT_EDGE, y], size: MUTATOR_FONT_SIZE,
                                 checked: user_data.inversion?) do |button, checked|
      user_data.inversion = checked
      create_level_buttons
    end

    self.gui_controls += [@hardcore, @inversion]

    # Buttons in a column on the right hand side of the screen.
    y = 28
    # User settings - controls.
    gui_controls << Button.new("Controls", self, at: [RIGHT_EDGE, y], size: FONT_SIZE,
                                 auto_center: [1, 0]) do
      push_scene :options_controls
    end

    y += gui_controls.last.height + BUTTON_SPACING

    # Toggle fullscreen/window.
    gui_controls << CheckButton.new('Fullscreen', self, at: [RIGHT_EDGE, y], size: FONT_SIZE, auto_center: [1, 0],
                                    checked: user_data.fullscreen?) do |button, checked|
      user_data.fullscreen = checked
      $create_window = true
      pop_scene
    end

    y += gui_controls.last.height + BUTTON_SPACING

    unless user_data.fullscreen?
      # Increase and reduce the size of the window.
      x = RIGHT_EDGE
      gui_controls << Button.new("+", self, at: [RIGHT_EDGE, y], size: FONT_SIZE,
                                 auto_center: [1, 0]) do
        scale_up
      end
      x -= gui_controls.last.width + BUTTON_SPACING

      @screen_size = ShadowText.new("0000x0000", at: [x, y + (FONT_SIZE - SMALL_FONT_SIZE) / 2.0],
                                    size: SMALL_FONT_SIZE, color: TEXT_COLOR, auto_center: [1, 0])
      gui_controls << @screen_size

      x -= gui_controls.last.width + BUTTON_SPACING

      gui_controls << Button.new("-", self, at: [x, y], size: FONT_SIZE,
                                 auto_center: [1, 0]) do
        scale_down
      end

      update_screen_size
    end

    y += gui_controls.last.height + BUTTON_SPACING

    gui_controls << Button.new("Quit", self, at: [RIGHT_EDGE, y], size: FONT_SIZE, auto_center: [1, 0]) do
      raise_event :quit
    end

    # Version number (top right).
    gui_controls << ShadowText.new("v#{ZedAndGinger::VERSION}", at: [RIGHT_EDGE, TOP_EDGE],
                                   size: SMALL_FONT_SIZE, color: TEXT_COLOR, auto_center: [1, 1])

    @@ambient_music ||= music music_path("Space_Cat_Ambient.ogg")
    @@ambient_music.looping = true
    @@ambient_music.play
    @@ambient_music.volume = 70

    window.icon = image image_path("window_icon.png")

    log.info { "#{self.class} loaded in #{Time.now - started_at}s" }
  end

  protected
  def create_level_buttons
    @level_buttons = []
    @level_numbers.each_with_index do |level, i|
      @level_buttons << Button.new(level.to_s, self, at: [LEFT_EDGE + 17 + i * (LEVEL_FONT_SIZE + BUTTON_SPACING), LEVELS_Y],
                                   size: LEVEL_FONT_SIZE, enabled: user_data.level_unlocked?(level, mode: user_data.mode)) do
        start_level level
      end
    end

    if DEVELOPMENT_MODE
      @level_buttons << Button.new("#{UserData::DEV_LEVEL}-dev", self, at: [RIGHT_EDGE, LEVELS_Y], size: LEVEL_FONT_SIZE,
                                 auto_center: [1, 0]) do
        start_level UserData::DEV_LEVEL
      end
    end

    add_level_button_events
  end

  def add_level_button_events
    remove_event_group :level_buttons

    @level_buttons.each {|b| b.register(self, group: :level_buttons) }
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
          x_in_sprite, y_in_sprite = x % 16, y % 16
          Zed::SKIN_COLORS[(x_in_sprite + y_in_sprite + column) % Zed::SKIN_COLORS.size]
        end
      end
    end

    @zed = sprite @@zed_image, at: [17, 55]
    @zed.scale = [2, 2]

    # Create Ginger.
    @ginger = sprite image_path("player.png"), at: [48, 55]
    @ginger.scale = [2, 2]

    @zed.sheet_size = @ginger.sheet_size = [8, 5]
    @zed.origin = @ginger.origin = [@zed.sprite_width / 2, @zed.sprite_height]

    # Buttons to choose to play one or both cats.
    @cat_buttons = {}
    @cat_buttons[:zed] = Button.new('Zed', self, at: [13, 32], size: FONT_SIZE,
                             disabled_color: Color.red) do
      enable_cat_buttons(:zed)
      @cat_animations[:walking1].start @zed
      @cat_animations[:sitting].start @ginger
      @cat_animations[:walking2].pause
    end

    x = @cat_buttons[:zed].x + @cat_buttons[:zed].width + 2
    @cat_buttons[:both] = Button.new('Both', self, at: [x, 32], size: FONT_SIZE,
                                disabled_color: Color.red) do
      enable_cat_buttons(:both)
      @cat_animations[:walking1].start @zed
      @cat_animations[:walking2].start @ginger
      @cat_animations[:sitting].pause
    end

    x = @cat_buttons[:both].x + @cat_buttons[:both].width + 2
    @cat_buttons[:ginger] = Button.new('Ginger', self, at: [x, 32], size: FONT_SIZE,
                                disabled_color: Color.red) do
      enable_cat_buttons(:ginger)
      @cat_animations[:sitting].start @zed
      @cat_animations[:walking1].start @ginger
      @cat_animations[:walking2].pause
    end

    @player_sheets = {
        zed: @@zed_image,
        ginger: @ginger_image,
    }

    @cat_buttons[user_data.selected_cat].activate

    self.gui_controls += [@zed, @ginger] + @cat_buttons.values
  end

  protected
  def enable_cat_buttons(name)
    user_data.selected_cat = name
    @cat_buttons.each_key {|key| @cat_buttons[key].enabled = (key != name) }
  end

  protected
  def scale_up
    new_size = GAME_RESOLUTION * (user_data.scaling + 2)
    if new_size.x <= Ray.screen_size.width * 0.95 and
       new_size.y <= Ray.screen_size.height * 0.95
      user_data.scaling = user_data.scaling + 2
    end
  end

  protected
  def scale_down
    if user_data.scaling >= 4
      user_data.scaling = user_data.scaling - 2
    end
  end

  protected
  def scaling=(scaling)
    pop_scene
    user_data.scaling = scaling
    window.size = GAME_RESOLUTION * user_data.scaling
    push_scene name
    update_screen_size
  end

  protected
  def update_screen_size
    @screen_size.string = ("%dx%d" % (GAME_RESOLUTION * user_data.scaling).to_a).rjust(9)
  end

  public
  def clean_up
    @@ambient_music.pause
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
      @@ambient_music.play
    end

    on :focus_loss do
      @@ambient_music.pause
    end
  end

  def update
    super

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

    @level_buttons.each {|b| b.draw_on win }

    super(win)
  end
end
