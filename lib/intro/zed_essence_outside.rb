class ZedEssenceOutside < GameObject
  def recording?; @state == :recording; end
  def playing?; @state == :playing; end

  def initialize(scene, position, options = {})
    options = {
        position_tracker_file: File.expand_path("config/intro/zed_outside_position.yml", EXTRACT_PATH),
        state: :playing,
    }.merge! options

    @position_tracker_file, @state = options[:position_tracker_file], options[:state]

    raise "bad state #{@state}" unless playing? or recording?

    sprite = sprite image(image_path("glow.png")), color: Color.new(255, 0, 255, 255), at: position
    sprite.blend_mode = :add
    sprite.origin = sprite.image.size / 2
    sprite.scale = [0.1, 0.1]

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

  def update
    @sprite.scale = [0.1 + Math::sin((Time.now - @created_at) * 5) * 0.02] * 2

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
end
