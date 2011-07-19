require_relative "dynamic_object"

class Player < DynamicObject
  ANIMATION_DURATION = 1

  ACCELERATION = 40
  DECELERATION = -40
  MIN_SPEED = 0
  MAX_SPEED = 64

  def casts_shadow?; true; end

  def to_rect; Rect.new(@sprite.x - 5, @sprite.y - 3, 10, 6) end

  def initialize(scene, position)
    sprite = sprite image_path("player.png"), at: position    
    sprite.sheet_size = [4, 2]
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height]

    super(scene, sprite, position)

    floor_rect = scene.floor_map.to_rect
    @rect = Rect.new(floor_rect.x + floor_rect.width * 0.1,
                     floor_rect.y + FloorTile::HEIGHT * 0.5,
                     floor_rect.width * 0.4,
                     floor_rect.height - FloorTile::HEIGHT * 2)
    @velocity_x = 0.0

    walk_animation
  end

  def screen_offset_x
    # 0.2..0.5 across the screen.
    0.2 + (@velocity_x / MAX_SPEED) * 0.3
  end

  def speed
    speed = @velocity_x
    speed *= @tile.speed if z == 0 and @tile

    speed
  end
  
  def walk_animation
    @animations.clear
    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION / 2.0).start(@sprite)
    @animations.each(&:loop!)          
  end
  
  def register(scene)
    super(scene)
    
    on :key_press, key(:space) do
      @velocity_z = 1.5 unless z > 0
    end
  end
  
  def update
    if holding? :w or holding? :up
      self.y = [@rect.y, y - 1].max
    elsif holding? :s or holding? :down
      self.y = [@rect.y + @rect.height, y + 1].min
    end

    if z == 0
      if holding? :a or holding? :left
        @velocity_x += DECELERATION * frame_time
        @velocity_x = [@velocity_x, MIN_SPEED].max
      elsif holding? :d or holding? :right
        @velocity_x += ACCELERATION * frame_time
        @velocity_x = [@velocity_x, MAX_SPEED].min
      end
    end

    self.position += [speed * frame_time, 0]

    @tile = scene.floor_map.tile_at_coordinate(position)
    #@tile.touched_by(self) if @tile
    
    super
  end
end