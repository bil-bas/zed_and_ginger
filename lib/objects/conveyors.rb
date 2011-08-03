require_relative 'game_object'

class Conveyor < GameObject
  SPEED = 24.0 # Pixels/second
  IMAGE = image_path("conveyor.png")

  def to_rect; Rect.new(*(@position - [4, 3]), 8, 6) end

  def initialize(map, tile, position)
    sprite = sprite IMAGE, at: position.to_vector2 + [tile.grid_position.y * 3, 0]

    super(map.scene, sprite, position)
    @scroll_rect = Rect.new(0, 0, *@sprite.image.size)

    init_sprite
  end

  def collide?(other)
    other.z == 0 and other.pos.inside? self and not other.riding?
  end

  def z_order
    Player::Z_ORDER_SQUASHED - 1
  end

  def update
    scene.players.each do |player|
      if collide? player
        player.pos += direction * SPEED * frame_time
      end
    end

    @scroll_rect.y = scene.timer.elapsed * SPEED
    @sprite.sub_rect = @scroll_rect
  end
end

# Pushes player to the left (up on the screen)
class LeftConveyor < Conveyor
  def direction; Vector2[0, -1]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.image.width / 2, @sprite.image.height / 2] + [1.5, 0]
    @sprite.scale_y = 0.75
    @sprite.skew_x(FloorTile::SKEW * 0.75)
  end
end

# Pushes player to the right (down on the screen)
class RightConveyor < Conveyor
  def direction; Vector2[0, 1]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.image.width / 2, @sprite.image.height / 2] + [1.5, 0]
    @sprite.angle = 180
    @sprite.scale_y = 0.75
    @sprite.skew_x(FloorTile::SKEW * 0.75)
  end
end

# Pushes player forward (faster) (right on the screen)
class ForwardConveyor < Conveyor
  def direction; Vector2[1, 0]; end

  def init_sprite
    @sprite.origin = Vector2[@sprite.image.width / 2, @sprite.image.height / 2] + [0, -1.5]
    @sprite.angle = 90
    @sprite.scale_x = 0.75
    @sprite.skew_y(FloorTile::SKEW * -0.75)
  end
end

# Pushes player backwards (slower) (left on the screen)
class BackwardConveyor < Conveyor
  def direction; Vector2[-1, 0]; end
  def init_sprite
    @sprite.origin = Vector2[@sprite.image.width / 2, @sprite.image.height / 2] + [0, -1.5]
    @sprite.angle = 270
    @sprite.scale_x = 0.75
    @sprite.skew_y(FloorTile::SKEW * -0.75)
  end
end

