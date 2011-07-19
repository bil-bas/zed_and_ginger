class Spring < DynamicObject
  JUMP_SPEED = 8

  def to_rect; Rect.new(@sprite.x - 2, @sprite.y - 1, 4, 2) end

  def initialize(scene, position)
    sprite = sprite image_path("spring.png"), at: position
    sprite.sheet_size = [2, 1]
    sprite.origin = Vector2[sprite.sprite_width, sprite.sprite_height] / 2

    super(scene, sprite, position)
  end

  def update
    player = scene.player
    if player.z == 0 and collide? player
      @sprite.sheet_pos = [1, 0]
      # Todo: Boing sound.
      player.z += 0.000001 # Just so we only collide once.
      player.velocity_z = 3
    end

    super
  end
end
