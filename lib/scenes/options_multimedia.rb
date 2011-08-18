class OptionsMultimedia < GuiScene
  public
  def register
    super

    on :key_press, key(:escape) do
      pop_scene
    end
  end

  public
  def setup
    super()

    y = 0

    gui_controls << ShadowText.new("Options", at: [TITLE_X, y], size: HEADING_SIZE)
    y += gui_controls.last.height + LINE_SPACING * 3

    @play_sound_on_effects = false # Don't play effect sound unless slider moved.
    y = volume_sliders("Effects volume", :effects_volume, y)
    @play_sound_on_effects = true
    y = volume_sliders("Music volume", :music_volume, y)

    # GRAPHICS OPTIONS.
    y = sub_heading(y, "Graphics")
    y += LINE_SPACING * 4

    # Toggle fullscreen/window.
    x = LABEL_X
    gui_controls << CheckButton.new('Fullscreen', at: [x, y], size: ITEM_SIZE,
                                    checked: user_data.fullscreen?, tip: "Toggle fullscreen/windowed") do |button, checked|
      user_data.fullscreen = checked
      $create_game_with_scene = :options_multimedia
      pop_scene_while {|scene| scene }
      window.close
    end
    x += 40

    unless user_data.fullscreen?
      # Increase and reduce the size of the window.
      gui_controls << Button.new("-", at: [x, y], size: ITEM_SIZE, tip: "Decrease window size") do
        scale_down
      end
      x += gui_controls.last.width + LINE_SPACING
    end

    @screen_size = ShadowText.new("0000x0000", at: [x, y], size: ITEM_SIZE, color: LABEL_COLOR)
    gui_controls << @screen_size
    x += gui_controls.last.width + LINE_SPACING

    unless user_data.fullscreen?
      gui_controls << Button.new("+", at: [x, y], size: ITEM_SIZE, tip: "Increase window size") do
        scale_up
      end
    end

    update_screen_size

    back_button
  end

  protected
  def volume_sliders(title, method, y)
    # Heading
    y = sub_heading(y, title)
    y += LINE_SPACING * 4

    # Slider
    initial = user_data.send method
    slider = RadioGroup.new(at: [LABEL_X, y], initial_value: initial, spacing: 0,
                                     default_button_options: { size: ITEM_SIZE }) do |value|
      user_data.send :"#{method}=", value
      reset_ambient_music_volume

      if method == :effects_volume and @play_sound_on_effects
        @key_press_sound ||= sound sound_path("player_jump.ogg").dup
        @key_press_sound.volume = 15 * (value / 50.0)
        @key_press_sound.play
      end
    end
    gui_controls << slider

    (0..100).step(5) do |i|
      title = case i
        when 0  then 'Mute'
        when 50 then ' 50%'
        when 100 then ' 100%'
        else         ' |'
      end
      gui_controls.last.button(title, i, shortcut: nil, brackets: false, tip: "#{i}% volume")
    end

    y += gui_controls.last.height + LINE_SPACING * 4

    y
  end

  protected
  def scale_up
    new_size = GAME_RESOLUTION * (user_data.scaling + 2)
    if new_size.x <= Ray.screen_size.width * 0.95 and
       new_size.y <= Ray.screen_size.height * 0.95
      self.scaling = user_data.scaling + 2
    end
  end

  protected
  def scale_down
    if user_data.scaling >= 4
      self.scaling = user_data.scaling - 2
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
  def update
    background.update frame_time
    super
  end

  public
  def render(win)
    background.draw_on win
    super
  end
end
