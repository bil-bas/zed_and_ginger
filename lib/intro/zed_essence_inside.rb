require_relative "zed_essence_outside"

class ZedEssenceInside < ZedEssenceOutside
  def initialize(scene, position, options = {})
    options = {
        position_tracker_file: File.expand_path("config/intro/zed_inside_position.yml", EXTRACT_PATH),
    }.merge! options

    super(scene, position,options)
  end

  def relative_mouse_position
    @initial_position + (mouse_pos - @initial_mouse_pos) * 1.25 / scene.user_data.scaling
  end

  def tracking_complete
    # Do nothing.
  end

  def create_echo
    Echo.new(scene, @sprite.dup, position + [16, -30])
  end

  def rescale
    if @position_tracker.size < 20
      @sprite.scale *= 0.95
    else
      @sprite.scale = [0.1 + Math::sin((Time.now - @created_at) * 5) * 0.02] * 2
    end
  end
end
