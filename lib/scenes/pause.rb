require_relative 'game_scene'

class Pause < GameScene
  def setup(previous_scene)
    super()

    @previous_scene = previous_scene

    gui_controls << ShadowText.new("Paused", at: [22, 15], size: 26,
                              color: Color.new(255, 255, 255, 150),
                              shadow_color: Color.new(0, 0, 0, 150))
  end

  def register
    on :key_press, key(:escape) do
      pop_scene
    end

    on :key_press, *key_or_code(window.user_data.control(:pause)) do
      pop_scene
    end
  end

  def render(win)
    @previous_scene.render(win)
    super(win)
  end
end