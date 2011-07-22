require_relative "game_object"

class DynamicObject < GameObject
  GRAVITY = 8

  attr_accessor :velocity_z
 
  def shadow_shape; Vector2[1, 1]; end
 
  def initialize(scene, sprite, position)
    @velocity_z = 0
    @animations = []
    
    super(scene, sprite, position)

    @shadow.scale *= shadow_shape
  end
  
  def update
    if @velocity_z != 0 or z > 0
      @velocity_z -= GRAVITY * frame_time
      self.z += @velocity_z
      
      if z <= 0
        self.z = 0
        @velocity_z = 0
      end

      shadow_scale = 0.06 * ((40 - z) / 40.0)
      @shadow.scale = Vector2[shadow_scale, shadow_scale] * shadow_shape
    end

    @animations.each(&:update)
  end
  
  def animated?
    @animations.any?(&:running?)
  end
end