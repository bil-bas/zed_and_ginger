require_relative "gui_scene"

class DialogScene < GuiScene
  attr_reader :run_result, :previous_scene

  def setup(previous_scene, options = {})
    @previous_scene = previous_scene
    @run_result = nil
    super(options)
  end

  def pop_scene(return_value)
    @run_result = return_value
    exit!
  end

  def render(win)
    @previous_scene.render(win)

    super(win)
  end
end