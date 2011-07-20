require_relative "dynamic_object"

class Player < DynamicObject
  ANIMATION_DURATION = 0.4

  ACCELERATION = 40
  DECELERATION = -40
  MIN_SPEED = 0
  MAX_SPEED = 64
  VERTICAL_SPEED = 16

  def shadow_shape; Vector2[1.2, 0.6]; end
  def casts_shadow?; true; end

  def to_rect; Rect.new(@sprite.x - 5, @sprite.y - 3, 10, 6) end

  def initialize(scene, position)
    sprite = sprite image_path("player.png"), at: position    
    sprite.sheet_size = [4, 4]
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height]

    super(scene, sprite, position)

    floor_rect = scene.floor_map.to_rect
    @rect = Rect.new(floor_rect.x + floor_rect.width * 0.1,
                     floor_rect.y + FloorTile::HEIGHT * 0.5,
                     floor_rect.width * 0.4,
                     floor_rect.height - FloorTile::HEIGHT)
    @velocity = Vector2[0, 0]

    walk_animation
  end

  def screen_offset_x
    # 0.2..0.5 across the screen.
    0.2 + (@velocity.x / MAX_SPEED) * 0.3
  end

  def effective_velocity
    velocity = @velocity.dup
    velocity *= @tile.speed if z == 0 and @tile

    velocity
  end
  
  def walk_animation
    @animations.clear
    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.each(&:loop!)          
  end
  
  def register(scene)
    super(scene)
    
    on :key_press, key(:space) do
      @velocity_z = 1.5 unless z > 0
    end
  end
  
  def update
    @velocity.y = if holding? :w or holding? :up
      -VERTICAL_SPEED
    elsif holding? :s or holding? :down
      +VERTICAL_SPEED
    else
      0
    end

    if z == 0
      if holding? :a or holding? :left
        @velocity.x += DECELERATION * frame_time
        @velocity.x = [@velocity.x, MIN_SPEED].max
      elsif holding? :d or holding? :right
        @velocity.x += ACCELERATION * frame_time
        @velocity.x = [@velocity.x, MAX_SPEED].min
      end
    end

    self.position += effective_velocity * frame_time
    self.y = [[position.y, @rect.y].max, @rect.y + @rect.height].min

    @tile = scene.floor_map.tile_at_coordinate(position)
    #@tile.touched_by(self) if @tile
    
    super
  end
end