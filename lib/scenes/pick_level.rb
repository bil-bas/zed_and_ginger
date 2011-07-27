require_relative 'gui_scene'

module Ginger
  EYE_COLOR = Color.new(79, 207, 108)
end
module Zed
  EYE_COLOR = Color.new(255, 0, 255)
  SKIN_COLORS = [Color.new(70, 0, 70), Color.new(50, 0, 50), Color.new(40, 0, 40), Color.new(30, 0, 30)]
end

class PickLevel < GuiScene
  TUTORIAL_LETTER = 'T'

  TITLE_COLOR = Color.new(255, 150, 0)
  BUTTON_COLOR = Color.white
  TEXT_COLOR = Color.new(200, 200, 200)
  DISABLED_COLOR = Color.new(100, 100, 100)

  FLOOR_TILES = [
      "--------",
      "--------",
  ]

  attr_reader :background, :background_camera

  public
  def setup(player_number = 0)
    @player_number = player_number

    super()

    create_background
    create_floor
    create_cats

    gui_controls << ShadowText.new("Zed and Ginger", at: [5, 0], size: 16, color: TITLE_COLOR)
    gui_controls << ShadowText.new("Level: ", at: [5, 14], size: 6, color: TEXT_COLOR)

    # Get the numbers of all the levels defined.
    levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    levels.map! {|file| File.basename(file).to_i }.sort!
    levels -= [UserData::DEV_LEVEL]

    levels.each_with_index do |level, i|
      gui_controls << Button.new(level.to_s, self, at: [20 + i * 8, 14], size: 6, color: BUTTON_COLOR,
                                 enabled: window.user_data.level_unlocked?(level)) do
        start_level level
      end
    end

    if DEVELOPMENT_MODE
      gui_controls << Button.new("#{UserData::DEV_LEVEL}-dev", self, at: [75, 14], size: 6, color: BUTTON_COLOR) do
        start_level UserData::DEV_LEVEL
      end
    end

    # Increase and reduce the size of the window.
    gui_controls << Button.new("-", self, at: [64, 52], size: 6, color: BUTTON_COLOR) do
      scale_down
    end

    @screen_size = ShadowText.new("0000x0000", at: [71, 52.5], size: 5, color: TEXT_COLOR)
    gui_controls << @screen_size
    update_screen_size
    gui_controls << Button.new("+", self, at: [88, 52], size: 6, color: BUTTON_COLOR) do
      scale_up
    end

    # Version number.
    gui_controls << ShadowText.new("v#{ZedAndGinger::VERSION}", at: [86, 0], size: 4, color: TEXT_COLOR)

    @@ambient_music ||= music music_path("Space_Cat_Ambient.ogg")
    @@ambient_music.looping = true
    @@ambient_music.play
    @@ambient_music.volume = 70
  end

  protected
  def create_floor
    @floor_map = FloorMap.new self, FLOOR_TILES, CheckeredFloor, []
  end

  protected
  def create_cats
    @ginger_image = Image.new image_path("player.png")

    # Animations
    @walking_animation = sprite_animation from: Player::WALKING_ANIMATION[0],
                                      to: Player::WALKING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION * 2
    @walking_animation.loop!

    @sitting_animation = sprite_animation from: Player::SITTING_ANIMATION[0],
                                         to: Player::SITTING_ANIMATION[1],
                                         duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @sitting_animation.loop!

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

    # Buttons
    @zed_button = Button.new('Zed', self, at: [14, 37], size: 6, color: BUTTON_COLOR,
                             disabled_color: Color.red) do
      @player_number = 0
      @zed_button.enabled = false
      @ginger_button.enabled = true
      @sitting_animation.start @ginger
      @walking_animation.start @zed
    end

    @ginger_button = Button.new('Ginger', self, at: [40, 37], size: 6, color: BUTTON_COLOR,
                                disabled_color: Color.red) do
      @player_number = 1
      @zed_button.enabled = true
      @ginger_button.enabled = false
      @sitting_animation.start @zed
      @walking_animation.start @ginger
    end

    @player_sheets = [@@zed_image, @ginger_image]
    [@zed_button, @ginger_button][@player_number].activate

    self.gui_controls += [@zed, @ginger, @zed_button, @ginger_button]
  end

  protected
  def scale_up
    new_size = GAME_RESOLUTION * (window.user_data.scaling + 2)
    if new_size.x <= Ray.screen_size.width * 0.95 and
       new_size.y <= Ray.screen_size.height * 0.95
      self.scaling = window.scaling + 2
    end
  end

  protected
  def scale_down
    if window.user_data.scaling >= 4
      self.scaling = window.scaling - 2
    end
  end

  protected
  def scaling=(scaling)
    pop_scene
    window.scaling = scaling
    window.size = GAME_RESOLUTION * window.scaling
    push_scene :pick_level, @player_number
    update_screen_size
  end

  protected
  def update_screen_size
    @screen_size.string = ("%dx%d" % (GAME_RESOLUTION * window.scaling).to_a).rjust(9)
  end

  protected
  def create_background
    unless defined? @@background_image
      @@background_image = Image.new GAME_RESOLUTION * 4
      image_target @@background_image do |target|
        target.clear Color.new(0, 0, 25)
        target.update
      end

      # Draw on some stars.
      400.times do
        star_pos = [rand(@@background_image.size.width), rand(@@background_image.size.height)]
        @@background_image[*star_pos] = Color.new(*([55 + rand(200)] * 3))
      end

      # Add the moon and a sprinkling of asteroids.
      moon = sprite image(image_path("moon.png")),
                  at: [310, 18],
                  scale: Vector2[4, 4]

      asteroid = sprite image(image_path("asteroid.png"))
      image_target @@background_image do |target|
        target.draw moon
        20.times do
          rock_pos = Vector2[150 + rand(100), rand(@@background_image.size.height)]
          rock_pos.x += rock_pos.y / 3.0
          asteroid.pos = rock_pos
          asteroid.scale = [0.5 + rand() * 0.3] * 2
          brightness = 50 + rand(100)
          asteroid.color = Color.new(*[brightness] * 3)
          target.draw asteroid
        end
        target.update
      end
    end

    @background = sprite @@background_image
    @background.scale = [0.25] * 2
  end

  public
  def clean_up
    @@ambient_music.pause
  end

  protected
  def start_level(level_number)
    push_scene :level, level_number, @background, @player_sheets[@player_number]
  end

  public
  def register
    super

    window.icon = image image_path("window_icon.png")

    on :focus_gain do
      @@ambient_music.play
    end

    on :focus_loss do
      @@ambient_music.pause
    end

    always do
      @sitting_animation.update
      @walking_animation.update
    end
  end

  public
  def render(win)
    win.draw @background

    floor_camera = win.view
    floor_camera.size = GAME_RESOLUTION * window.scaling
    floor_camera.zoom_by window.scaling * 2
    floor_camera.x = 30.5
    floor_camera.y = -8
    win.with_view floor_camera do
      @floor_map.draw_on win
    end

    super(win)
  end
end
