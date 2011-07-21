class Pause < Scene
  def setup(previous_scene)
    @previous_scene = previous_scene

    @message = ShadowText.new "-Paused -", at: [300, 70], font: FONT_NAME, size: 60
  end

  def register
    on :key_press, key(:escape) do
      pop_scene
    end

    render do |win|
      @previous_scene.render(win)

      @message.draw_on win
    end
  end
end