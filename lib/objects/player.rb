require_relative "dynamic_object"

class Player < DynamicObject
  ANIMATION_DURATION = 2

  ACCELERATION = 40
  DECELERATION = -40
  MIN_SPEED = 0
  MAX_SPEED = 64
  VERTICAL_SPEED = 16
  MIN_RUN_VELOCITY = 70 # Above this, run animation; below walk.
  JUMP_SPEED = 1.5 # Z-speed of jumping.

  FOUR_FRAME_ANIMATION_DURATION = 1

  # 8 frames of walking.
  WALKING_ANIMATION = [[0, 0], [7, 0]]

  # 8 frames of running.
  RUNNING_ANIMATION = [[0, 1], [7, 1]]

  # 1 frame sitting.
  SITTING_ANIMATION = [[0, 2], [3, 2]]

  # 3 frames jumping.
  JUMP_UP_SPRITE = [4, 2]
  JUMP_ACROSS_SPRITE = [5, 2]
  JUMP_DOWN_SPRITE = [6, 2]

  # 4 frames dancing.
  DANCING_ANIMATION = [[0, 3], [3, 3]]

  # 4 frames surfing.
  SURFING_ANIMATION = [[0, 4], [3, 4]]

  def shadow_shape; Vector2[1.2, 0.6]; end
  def casts_shadow?; true; end

  def to_rect; Rect.new(@sprite.x - 5, @sprite.y - 3, 10, 6) end

  def initialize(scene, position)
    sprite = sprite image_path("player.png"), at: position    
    sprite.sheet_size = [8, 5]
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height]

    super(scene, sprite, position)

    floor_rect = scene.floor_map.to_rect
    @rect = Rect.new(floor_rect.x + floor_rect.width * 0.1,
                     floor_rect.y + FloorTile::HEIGHT * 0.5,
                     floor_rect.width * 0.4,
                     floor_rect.height - FloorTile::HEIGHT)
    @velocity = Vector2[0, 0]

    @sprite.scale *= 0.75

    create_animations
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
  
  def create_animations
    @player_animations = {}

    [
        [:sitting, SITTING_ANIMATION, FOUR_FRAME_ANIMATION_DURATION],
        [:walking, WALKING_ANIMATION, 1], # Duration based on current speed.
        [:running, RUNNING_ANIMATION, 1], # Duration based on current speed.
        [:dancing, DANCING_ANIMATION, FOUR_FRAME_ANIMATION_DURATION],
        [:surfing, SURFING_ANIMATION, FOUR_FRAME_ANIMATION_DURATION],
    ].each do |name, frames, duration|


      @player_animations[name] = sprite_animation(from: frames[0],
                                                  to: frames[1],
                                                  duration: duration)
    end

    @player_animations.each_value do |anim|
      anim.loop!
      anim.start(@sprite)
    end
  end
  
  def register(scene)
    super(scene)
    
    on :key_press, key(:space) do
      @velocity_z = JUMP_SPEED unless z > 0
    end
  end

  def dance
    @player_animations[:dancing].update
  end
  
  def update
    if @tile.is_a? FinishFloor
      super
      if z > 0
        @sprite.sheet_pos = JUMP_DOWN_SPRITE
      else
        dance
      end
      return
    end

    # Move up and down.
    @velocity.y = if holding? :w or holding? :up
      -VERTICAL_SPEED
    elsif holding? :s or holding? :down
      +VERTICAL_SPEED
    else
      0
    end

    # Accelerate and decelerate.
    if holding? :a or holding? :left
      @velocity.x += DECELERATION * frame_time
      @velocity.x = [@velocity.x, MIN_SPEED].max
    elsif holding? :d or holding? :right
      @velocity.x += ACCELERATION * frame_time
      @velocity.x = [@velocity.x, MAX_SPEED].min
    end

    self.position += effective_velocity * frame_time
    self.y = [[position.y, @rect.y].max, @rect.y + @rect.height].min

    @tile = scene.floor_map.tile_at_coordinate(position)

    if z == 0
      # Sitting, running or walking.
      vel = effective_velocity.x
      if vel == 0
        @player_animations[:sitting].update
      elsif vel >= MIN_RUN_VELOCITY
        @player_animations[:running].duration = (80 - vel) / 20.0
        @player_animations[:running].update
      else
        @player_animations[:walking].duration = (80 - vel) / 20.0
        @player_animations[:walking].update
      end
    else
      # Jumping up, down or across (last at apex of jump).
      if @velocity_z > 0.4
        @sprite.sheet_pos = JUMP_UP_SPRITE
      elsif @velocity_z < -0.4
        @sprite.sheet_pos = JUMP_DOWN_SPRITE
      else
        @sprite.sheet_pos = JUMP_ACROSS_SPRITE
      end
    end
    
    super
  end
end