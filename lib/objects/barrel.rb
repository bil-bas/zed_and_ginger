require_relative "dynamic_object"

class Barrel < DynamicObject
  MOVE_SPEED = 15
  ANIMATION_DURATION = 1

  def initialize(scene, position)
    sprite = sprite image_path("barrel.png"), at: position - [2, 2]
    sprite.sheet_size = [4, 1]
    sprite.origin = [1, 6]

    super(scene, sprite, position)

    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.last.loop!
  end

  def update
    self.x -= MOVE_SPEED * frame_time
    super
  end
end