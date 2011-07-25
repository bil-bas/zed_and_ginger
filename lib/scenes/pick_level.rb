class PickLevel < Scene
  TUTORIAL_LETTER = 'T'

  attr_reader :background, :background_camera

  def setup
    @levels = Dir[File.join(EXTRACT_PATH, "config/levels/*.yml")]
    @levels.map! {|file| File.basename(file).to_i }.sort

    @heading = ShadowText.new("Zed and Ginger", at: [5, 0], size: 16, color: Color.new(255, 150, 0))
    @sub_heading = ShadowText.new("Level: ", at: [5, 14], size: 6)

    @level_buttons = []
    @level_labels = []
    level_button_handler = lambda do |button|
      start_level @levels[button.data]
    end

    @levels.each_with_index do |level, i|
      name = level == 0 ? 'T' : level.to_s
       if window.user_data.level_unlocked?(level) or DEVELOPMENT_MODE
        @level_buttons << Button.new(name, at: [20 + i * 8, 14], size: 6, data: i, &level_button_handler)
      else
        @level_labels << ShadowText.new(name, at: [20 + i * 8, 14], size: 6, color: Color.new(100, 100, 100))
      end
    end

    @scale_down_button = Button.new("-", at: [80, 50], size: 6) do
      scale_down
    end

    @scale_up_button = Button.new("+", at: [87, 50], size: 6) do
      scale_up
    end

    @cat = sprite image_path("player.png"), at: [12.5, 25]
    @cat.sheet_size = [8, 5]
    @cat_animation = sprite_animation from: Player::SITTING_ANIMATION[0],
                                      to: Player::SITTING_ANIMATION[1],
                                      duration: Player::FOUR_FRAME_ANIMATION_DURATION
    @cat_animation.loop!
    @cat_animation.start(@cat)
    @cat.scale = [2, 2]

    @version = ShadowText.new("v#{ZedAndGinger::VERSION}", at: [84, 56], size: 4)

    window.hide_cursor

    create_background

    cursor_image = image(image_path("cursor.png"))
    @cursor = sprite cursor_image, scale: [0.5, 0.5], origin: [0, 0]
    @cursor_shown = true

    @@ambient_music ||= music music_path("Space_Cat_Ambient.ogg")
    @@ambient_music.looping = true
    @@ambient_music.play
    @@ambient_music.volume = 70
  end

  def scale_up
    new_size = GAME_RESOLUTION * (window.user_data.scaling + 1)
    if new_size.x <= Ray.screen_size.width * 0.95 and
      new_size.y <= Ray.screen_size.height * 0.95
      pop_scene
      window.scaling  += 1
      window.size = new_size
      push_scene :pick_level
    end
  end

  def scale_down
    if window.user_data.scaling > 2
      pop_scene
      window.scaling -= 1
      window.size = GAME_RESOLUTION * window.scaling
      push_scene :pick_level
    end
  end

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

    @background_camera = window.default_view
    @background_camera.size = @@background_image.size
    @background_camera.center = @background_camera.size / 2
  end

  def clean_up
    @@ambient_music.pause
  end

  def start_level(level_number)
    push_scene :level, level_number, @background, @background_camera
  end

  def register
    # Allow key 1, 2, 3 to start level.
    on :text_entered do |char|
      char = Ray::TextHelper.convert(char).upcase
      char = '0' if char == TUTORIAL_LETTER or char == '`'
      if ('0'..'2').include? char and window.user_data.level_unlocked?(char.to_i)
        start_level char.to_i
      end
    end

    window.icon = image image_path("window_icon.png")

    # Allow mouse click on numeral to start level.
    on :mouse_press do |button, pos|
      if button == :left
        @level_buttons.each { |button| button.mouse_click pos }
        @scale_down_button.mouse_click pos
        @scale_up_button.mouse_click pos
      end
    end

    on :mouse_left do
      @cursor_shown = false
    end

    on :mouse_entered do
      @cursor_shown = true
    end

    on :focus_gain do
      @@ambient_music.play
    end

    on :focus_loss do
      @@ambient_music.pause
    end

    on :key_press, key(:plus) do
      scale_up
    end
    on :key_press, key(:minus) do
      scale_down
    end

    on :mouse_motion do |pos|
      @cursor.pos = pos / window.scaling
    end

    always do
      @cat_animation.update
    end
  end

  def render(win)
    win.with_view @background_camera do
      win.draw @background
    end

    win.with_view win.default_view do
      @heading.draw_on win
      @sub_heading.draw_on win
      @level_buttons.each {|item| item.draw_on win }
      @level_labels.each {|item| item.draw_on win }
      @scale_up_button.draw_on win
      @scale_down_button.draw_on win
      @version.draw_on win
    end

    win.draw @cat

    win.draw @cursor if @cursor_shown
  end
end
