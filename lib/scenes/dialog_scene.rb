require_relative "gui_scene"

class DialogScene < GuiScene
  attr_reader :run_result

  def setup(previous_state, options = {})
    @previous_state = previous_state
    @run_result = nil
    super(options)
  end

  def pop_scene(return_value)
    @run_result = return_value
    exit!
  end

  def render(win)
    @previous_state.render(win)

    super(win)
  end
end