require_relative 'dynamic_object'

class Conveyor < DynamicObject
  SPEED = 16.0
  NUM_FRAMES = 8

  def to_rect; Rect.new(*(@position - [4, 3]), 8, 6) end

  def initialize(map, tile, position)
    sprite = sprite image_path("conveyor.png"), at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    sprite.sheet_size = [NUM_FRAMES, 1]

    super(map.scene, sprite, position)

    init_sprite
  end

  def collide?(other)
    other.z == 0 and other.pos.inside? self and not other.riding?
  end

  def z_order
    Player::Z_ORDER_SQUASHED - 1
  end

  def update
    # Can't use an animation, since we want all animations to synchronize (even if not animated).
    next_frame = [((scene.timer.elapsed * SPEED) % NUM_FRAMES).floor, 0]
    @sprite.sheet_pos = next_frame

    player = scene.player

    if collide? player
      pos = player.pos
      player.pos = pos + (direction * SPEED * frame_time)
    end
  end
end

# Pushes player to the left (up on the screen)
class LeftConveyor < Conveyor
  def direction; Vector2[0, -1]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.sprite_width / 2, @sprite.sprite_height / 2] + [1.5, 0]
    @sprite.scale_y = 0.75
    @sprite.skew_x(FloorTile::SKEW * 0.75)
  end
end

# Pushes player to the right (down on the screen)
class RightConveyor < Conveyor
  def direction; Vector2[0, 1]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.sprite_width / 2, @sprite.sprite_height / 2] + [1.5, 0]
    @sprite.angle = 180
    @sprite.scale_y = 0.75
    @sprite.skew_x(FloorTile::SKEW * 0.75)
  end
end

# Pushes player forward (faster) (right on the screen)
class ForwardConveyor < Conveyor
  def direction; Vector2[1, 0]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.sprite_width / 2, @sprite.sprite_height / 2] + [0, -1.5]
    @sprite.angle = 90
    @sprite.scale_x = 0.75
    @sprite.skew_y(FloorTile::SKEW * -0.75)
  end
end

# Pushes player backwards (slower) (left on the screen)
class BackwardConveyor < Conveyor
  def direction; Vector2[-1, 0]; end
  def init_sprite
    @sprite.origin = Vector2[@sprite.sprite_width / 2, @sprite.sprite_height / 2] + [0, -1.5]
    @sprite.angle = 270
    @sprite.scale_x = 0.75
    @sprite.skew_y(FloorTile::SKEW * -0.75)
  end
end
