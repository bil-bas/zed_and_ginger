require_relative "dynamic_object"

class Barrel < DynamicObject
  MOVE_SPEED = 15
  ANIMATION_DURATION = 1
  ORIGIN = [4, 8]

  def to_rect; Rect.new(*(@position - [3, 3]), 6, 6) end

  def z_order; super - 3; end # So it appear behind the player.

  def initialize(map, tile, position)
    sprite = sprite image_path("barrel.png")
    sprite.sheet_size = [4, 1]
    sprite.origin = ORIGIN

    super(map.scene, sprite, position)

    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.last.loop!
  end

  def collide?(other)
    other.z < 3 and super(other)
  end

  def update
    self.x -= MOVE_SPEED * frame_time

    player = scene.player
    if player.ok? and collide? player
      player.squash
    end

    super
  end
end