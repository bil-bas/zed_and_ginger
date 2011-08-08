class ZedAsteroid < GameObject

  def initialize(scene, position)
    sprite = sprite image(image_path("zed_asteroid.png")), at: position
    sprite.origin = sprite.image.size / 2

    super(scene, sprite, position)

    @glow = sprite image(image_path("glow.png")), color: Color.new(150, 0, 150, 150)
    @glow.blend_mode = :add
    @glow.origin = @glow.image.size / 2
    @glow.scale *= 0.125

  end

  def update
    @sprite.x -= 20 * frame_time
    @sprite.y += 3 * frame_time
    @sprite.angle += 50 * frame_time

    @glow.pos = @sprite.pos

    if @sprite.x < 30
      # Bit of a fudge to make the particles work outside the regular corridor system.
      scene.create_particle([@sprite.x - @sprite.y * 0.5, @sprite.y, 0.000001], gravity: 0, number: 60,
                            velocity: [-5, 0, 0], random_velocity: [10, 10, 0], random_position: [3, 3, 0],
                            color: Color.new(100, 0, 100), min_y: -Float::INFINITY, max_y: Float::INFINITY, fade_duration: 10)
      scene.remove_object(self)
    end
  end

  def draw_on(win)
    win.draw @sprite
    win.draw @glow
  end
end