class Asteroid < GameObject
  def initialize(scene, position)
    sprite = sprite image(image_path("asteroid.png")), at: position
    sprite.sheet_size = [3, 1]
    sprite.sheet_pos = [rand(3), 0]
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height / 2]
    sprite.scale = [0.8 + rand() * 0.4] * 2

    super(scene, sprite, position)

    @angular_speed = rand(100) - 50
  end

  def update
    self.x -= 1
    self.y += 0.1
    @sprite.angle += @angular_speed * frame_time

    scene.remove_object self if x < -50
  end
end
