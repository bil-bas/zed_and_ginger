require_relative "game_object"

class DynamicObject < GameObject
  GRAVITY = 8

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
      @velocity_z -= GRAVITY * frame_time
      self.z += @velocity_z
      
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

    @animations.each(&:update)

    super
  end
  
  def animated?
    @animations.any?(&:running?)
  end
end