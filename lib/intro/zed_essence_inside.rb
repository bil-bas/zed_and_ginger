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
    scene.create_zed
    scene.remove_object self
  end
end
