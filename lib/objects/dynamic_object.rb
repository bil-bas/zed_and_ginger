require_relative "game_object"

# An object that is affected by gravity.
class DynamicObject < GameObject
  # Earth gravity, assuming an 8-pixel square tile is 0.25m square. Objects are a bit smaller, since they are at 75%.
  # This means the cats are about 19cm tall, which is smallish even for a cat, but this fits in with the "required"
  # jump distances :D
  GRAVITY = 45.0 * -9.81

  MAX_HEIGHT_FOR_SHADOW = 50.0
  BASE_SHADOW_SCALE = 0.05
  MINIMUM_SHADOW_SCALE = BASE_SHADOW_SCALE / 20.0

  attr_accessor :velocity_z
 
  def shadow_width; 1; end
  def shadow_height; 1; end
 
  def initialize(scene, sprite, position)
    @velocity_z = 0
    @animations = []
    
    super(scene, sprite, position)

    @shadow.scale *= [shadow_width, shadow_height]
  end

  def update
    if @velocity_z != 0 or z > 0
      # Interpolate gravity's effect.
      velocity_change = GRAVITY * frame_time
      @velocity_z += velocity_change
      self.z += (@velocity_z - velocity_change * 0.5) * frame_time

      if z <= 0
        self.z = 0
        @velocity_z = 0
      end

      if casts_shadow?
        shadow_scale =  BASE_SHADOW_SCALE *
            [((MAX_HEIGHT_FOR_SHADOW - z) / MAX_HEIGHT_FOR_SHADOW), 1].min

        @shadow.scale = [shadow_scale * shadow_width, shadow_scale * shadow_height]
      end
    end

    super
  end
end