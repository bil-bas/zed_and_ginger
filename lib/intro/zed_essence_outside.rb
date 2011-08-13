class ZedEssenceOutside < GameObject
  COLOR = Color.new(255, 0, 255, 50)
  PIXELATED_IMAGE_SIZE = Vector2[7, 7]

  class << self
    def shader
      unless defined? @shader
        @shader = Shader.new frag: StringIO.new(read_shader("zed_essence.frag"))
        @shader[:pixel_width] = 1.0 / PIXELATED_IMAGE_SIZE.width
        @shader[:pixel_height] = 1.0 / PIXELATED_IMAGE_SIZE.height
      end

      @shader
    end

    def shader_time=(time)
      @shader[:time] = time if defined? @shader
    end
  end

  class Echo < GameObject
    def initialize(*args)
      super(*args)
      @sprite.shader = ZedEssenceOutside.shader
    end

    def update
      color = @sprite.color
      if color.red > 0
        color.red -= 10
        color.green -= 10
        color.blue -= 10
        @sprite.color = color
      else
        scene.remove_object self
      end
    end
  end

  def recording?; @state == :recording; end
  def playing?; @state == :playing; end

  def initialize(scene, position, options = {})
    options = {
        position_tracker_file: File.expand_path("config/intro/zed_outside_position.yml", EXTRACT_PATH),
        state: :playing,
    }.merge! options

    @position_tracker_file, @state = options[:position_tracker_file], options[:state]

    raise "bad state #{@state}" unless playing? or recording?

    sprite = sprite image(image_path("glow.png")), color: COLOR, at: position
    sprite.blend_mode = :add
    sprite.origin = sprite.image.size / 2
    sprite.scale = [0.1, 0.1]
    sprite.shader = ZedEssenceOutside.shader

    @created_at = Time.now

    super(scene, sprite, position)

    case @state
      when :recording
        @position_tracker = []
        @initial_mouse_pos = mouse_pos
        @initial_position = position.to_vector2

      when :playing
        @position_tracker = YAML::load_file(@position_tracker_file)
    end

    @sound = music music_path("zed_essence.ogg")
    @sound.volume = 10 * (scene.user_data.effects_volume / 50.0)
    @sound.looping = true
    @sound.play
  end

  def register(scene)
    super(scene)

    if @state == :recording
      log.info { "Recording Zed position" }
      on :key_press do
        save_tracker
      end
    end
  end

  def relative_mouse_position
    @initial_position + (mouse_pos - @initial_mouse_pos) * 1.25
  end

  def save_tracker
    log.info { "Wrote #{@position_tracker_file}" }
    File.open(@position_tracker_file, "w") {|f| f.puts @position_tracker.to_yaml }
  end

  def tracking_complete
    scene.next_intro
  end

  def create_echo
    Echo.new(scene, @sprite.dup, position)
  end

  def rescale
    if @position_tracker.size < 50
      @sprite.scale *= 0.95
    else
      @sprite.scale = [0.1 + Math::sin((Time.now - @created_at) * 5) * 0.02] * 2
    end
  end

  def update
    rescale

    create_echo

    case @state
      when :recording
        # Expand mouse position a bit, so we don't lose control outside the screen area where position isn't tracked.
        pos = relative_mouse_position
        self.pos = pos
        @position_tracker << pos.to_a

      when :playing
        pos = @position_tracker.shift
        if pos
          self.pos = pos
        else
          tracking_complete
        end
      else
        raise "bad state #{@state}"
    end
  end

  def quiet
    @sound.stop
  end
end
