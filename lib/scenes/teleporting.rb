class Teleporting < Scene
  SPEED = 100.0

  def setup(previous_scene, position)
    @previous_scene, @position = previous_scene, position
    @player = @previous_scene.player
    @overlay = Polygon.rectangle([0, 0, *window.size], Color.new(150, 50, 150, 150))

    @animation = translation from: @player.position,
                             to: position,
                             duration: @player.position.distance(position) / SPEED
    @animation.start(@player)
  end

  def register
    always do
      @animation.update
      @previous_scene.move_camera
      pop_scene unless @animation.running?
    end
  end

  def render(win)
    @previous_scene.render(win)
    win.draw @overlay
  end
end