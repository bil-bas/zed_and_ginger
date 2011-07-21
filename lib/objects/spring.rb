require_relative "dynamic_object"

class Spring < DynamicObject
  JUMP_Z_SPEED = 2
  JUMP_SPEED_MODIFIER = 1.3

  def to_rect; Rect.new(*(@position - [2, 2]), 4, 4) end

  def initialize(scene, position)
    sprite = sprite image_path("spring.png"), at: position
    sprite.sheet_size = [2, 1]
    sprite.origin = Vector2[sprite.sprite_width, sprite.sprite_height] / 2 + [-1, 0.5]

    @activated = false

    @bounce_sound = sound sound_path "spring_bounce.ogg"
    @bounce_sound.volume = 30

    super(scene, sprite, position)
  end

  def z_order
    @activated ? super : -1000
  end

  def collide?(other)
    super(other) and other.z == 0
  end

  def update
    player = scene.player

    if player.ok? and not @activated and collide? player
      @sprite.sheet_pos = [1, 0]
      # Todo: Boing sound.
      player.z += 0.000001 # Just so we only collide with ONE spring.
      player.velocity_z = JUMP_Z_SPEED
      @bounce_sound.play
      player.speed_modifier = JUMP_SPEED_MODIFIER
      @activated = true
    end

    super
  end
end
