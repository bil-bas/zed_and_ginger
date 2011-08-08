class ZedEssence < GameObject
  POSITION_TRACKER_FILE = File.expand_path("config/intro/zed_outside_position.yml", EXTRACT_PATH)

  def initialize(scene, position)
    sprite = sprite image(image_path("glow.png")), color: Color.new(255, 0, 255, 255), at: position
    sprite.blend_mode = :add
    sprite.origin = sprite.image.size / 2
    sprite.scale = [0.1, 0.1]

    #@state = :recording
    @state = :playing

    @created_at = Time.now

    super(scene, sprite, position)

    case @state
      when :recording
        @position_tracker = []
        @initial_mouse_pos = mouse_pos
        @initial_position = position.to_vector2

      when :playing
        @position_tracker = YAML::load_file(POSITION_TRACKER_FILE)
    end
  end

  def register(scene)
    super(scene)

    if @state == :recording
      log.info { "Recording Zed position" }
      on :key_press do
        log.info { "Wrote #{POSITION_TRACKER_FILE}" }
        File.open(POSITION_TRACKER_FILE, "w") {|f| f.puts @position_tracker.to_yaml }
      end
    end
  end

  def update
    @sprite.scale = [0.1 + Math::sin((Time.now - @created_at) * 5) * 0.02] * 2

    case @state
      when :recording
        # Expand mouse position a bit, so we don't lose control outside the screen area where position isn't tracked.
        pos = @initial_position + (mouse_pos - @initial_mouse_pos) * 1.25
        self.pos = pos
        @position_tracker << pos.to_a

      when :playing
        pos = @position_tracker.shift
        if pos
          self.pos = pos
        else
          scene.push_scene :intro_inside
        end
      else
        raise "bad state #{@state}"
    end
  end
end
