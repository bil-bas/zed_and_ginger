require_relative "intro_scene"

class IntroInside < IntroScene
  FLOOR_TILES = [
      "--------",
      "--------",
  ]

  def setup
    super()

    @maps = Maps.new(self, 0, :zed)
  end


  def update
    super()

    @visible_objects = (@objects + @particle_generator.particles).sort_by(&:z_order)
  end

  def render(win)
    background.draw_on(win)

    camera_view = win.view
    camera_view.y -= 3
    camera_view.x += 20
    win.with_view camera_view do
      @maps.wall.draw_on(win)
    end

    camera_view.y -= @maps.wall.to_rect.height
    win.with_view camera_view do
      @maps.floor.draw_on(win)
      @visible_objects.each {|o| o.draw_on(win) }
    end

    super(win)
  end
end
