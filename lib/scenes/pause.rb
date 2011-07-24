class Pause < Scene
  def setup(previous_scene)
    @previous_scene = previous_scene

    @message = ShadowText.new "-Paused -", at: [37.5, 8.75], size: 7.5
  end

  def register
    on :key_press, key(:escape) do
      pop_scene
    end
  end

  def render(win)
    @previous_scene.render(win)

    win.with_view win.default_view do
      @message.draw_on win
    end
  end
end