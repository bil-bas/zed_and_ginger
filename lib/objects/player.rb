require_relative "dynamic_object"

class Player < DynamicObject
  def speed; 64; end
  
  ANIMATION_DURATION = 1
  
  def initialize(scene, position)
    sprite = sprite image_path("player.png"), at: position    
    sprite.sheet_size = [4, 2]
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height - 4]
     
    super(scene, sprite, position)
       
    walk_animation([1, 0], 0)                         
  end
  
  def walk_animation(translation, sheet_row)
    @animations.clear
    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION / 2.0).start(@sprite)
    @animations << translation(of: translation.to_vector2 * speed, duration: ANIMATION_DURATION).start(self)
    
    @animations.each(&:loop!)          
  end
  
  def register(scene)
    super(scene)
    
    on :key_press, key(:space) do
      @velocity_z = 2 unless z > 0
    end
  end
  
  def update
    unless animated?
      #walk_animation([1, 0], 0)
      #if holding? :down
      #  if holding? :left
      #    direction = 
      #  elsif holding? :right
      #    direction = 
      #end
    end
    
    super
  end
end