require_relative "zed_essence"

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
    self.x -= 1
    self.y += 0.15
    @sprite.angle += 50 * frame_time

    @glow.pos = @sprite.pos

    if @sprite.x < 20
      explode_pixels(gravity: 0, number: 5,
                     velocity: [-5, 0, 0], random_velocity: [10, 10, 0],
                     min_y: -Float::INFINITY, max_y: Float::INFINITY, fade_duration: 10)
      scene.remove_object(self)
      ZedEssence.new(scene, [x, y])
    end
  end

  def draw_on(win)
    win.draw @sprite
    win.draw @glow
  end
end