require_relative "dynamic_object"

# Paces up and down.
class Pacer < DynamicObject
  MOVE_SPEED = 5
  ANIMATION_DURATION = 0.5

  def casts_shadow?; true; end
  def to_rect; Rect.new(*(@position - [4, 3]), 8, 6) end

  def initialize(map, tile, position)
    sprite = sprite image_path("pacer.png")
    sprite.sheet_size = [4, 1]
    sprite.origin = [sprite.sprite_width * 0.5, sprite.sprite_height]

    super(map.scene, sprite, position)

    @shadow.scale *= 0.75
    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.last.loop!

    @min_y = map.to_rect.y + map.tile_size.width / 2.0 - 1
    @max_y = map.to_rect.y + map.to_rect.height - map.tile_size.height / 2.0

    recalculate_direction
  end

  def recalculate_direction
    if y <= @min_y or not defined? @velocity_y
      @velocity_y = + MOVE_SPEED
      self.y = @min_y + (@min_y - y)
    elsif y >= @max_y
      @velocity_y = - MOVE_SPEED
      self.y = @max_y - (y - @max_y)
    end
  end

  def collide?(other)
    other.z < 6 and super(other)
  end

  def update
    self.y += @velocity_y * frame_time

    recalculate_direction

    scene.players.each do |player|
      if player.can_be_hurt? and collide? player
        player.electrocute
        scene.remove_object self
      end
    end

    super
  end
end
