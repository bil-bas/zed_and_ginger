require_relative "dynamic_object"

class Player < DynamicObject
  ANIMATION_DURATION = 2

  ACCELERATION = 40
  DECELERATION = -40
  MIN_SPEED = 0
  MAX_SPEED = 64
  VERTICAL_SPEED = 25
  MIN_RUN_VELOCITY = 100 # Above this, run animation; below walk.
  JUMP_SPEED = 1.5 # Z-speed of jumping.

  RIDING_OFFSET_X = -2 # Move ridden object back, since we have our origin far forward.
  SHADOW_OFFSET_X = -2
  SQUASH_OFFSET_Y = 3 # Distance moved when squashed.

  FOUR_FRAME_ANIMATION_DURATION = 1

  SCORE_PER_100_MS = 100
  SCORE_PER_TILE = 10

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
  SURFING_ANIMATION = [[4, 3], [7, 3]]

  # 1 dead frame.
  DEAD_SPRITE = [0, 4]
  SQUASHED_SPRITE = [1, 4]
  KNOCKED_OUT_SPRITE = DEAD_SPRITE

  attr_accessor :speed_modifier
  attr_writer :score

  def shadow_shape; Vector2[1.2, 0.6]; end
  def casts_shadow?; @state != :squashed; end
  def z_order; (@state == :squashed) ? 0 : super; end
  def to_rect; Rect.new(*(@position - [3, 2]), 6, 4) end
  def riding?; !!@riding_on; end
  def ok?; @state == :ok; end
  def squashed?; @state == :squashed; end
  def dead?; @state == :dead; end
  def finished?; @state == :finished; end
  def score; ((x - @initial_x).div(8) * SCORE_PER_TILE) + @score; end

  def x=(value)
    super(value)
    @shadow.x += SHADOW_OFFSET_X
    value
  end

  def initialize(scene, tile, position)
    @initial_x = position.x
    sprite = sprite image_path("player.png"), at: position    
    sprite.sheet_size = [8, 5]
    sprite.sheet_pos = SITTING_ANIMATION.first
    sprite.origin = [sprite.sprite_width * 0.75, sprite.sprite_height]

    super(scene, sprite, position)

    floor_rect = scene.floor_map.to_rect
    @rect = Rect.new(floor_rect.x + floor_rect.width * 0.1,
                     floor_rect.y + FloorTile.height * 0.5,
                     floor_rect.width * 0.4,
                     floor_rect.height - FloorTile.height)
    @velocity = Vector2[0, 0]

    @sprite.scale *= 0.75
    @riding_on = nil
    @state = :ok
    @speed_modifier = 1.0
    @score = 0

    @sounds = {}
    [:died, :jump, :squashed].each do |sound|
      @sounds[sound] = sound sound_path "player_#{sound}.ogg"
    end
    @sounds.each_value {|s| s.volume = 30 }

    create_animations
  end

  def screen_offset_x
    # 0.2..0.5 across the screen.
    0.2 + (@velocity.x / MAX_SPEED) * 0.3
  end

  def effective_velocity
    @velocity * @speed_modifier
  end

  def squash
    @state = :squashed
    @sprite.sheet_pos = SQUASHED_SPRITE
    self.z = 0
    self.velocity_z = 0
    @effect_time_remaining = 2
    self.y += SQUASH_OFFSET_Y
    @sounds[:squashed].play
  end

  def unsquash
    self.y -= SQUASH_OFFSET_Y
  end

  def knock_out
    @state = :knocked_out
    @sprite.sheet_pos = KNOCKED_OUT_SPRITE
    @effect_time_remaining = 2
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

  def ride(object)
    @riding_on = object
  end

  def stop_riding
    if riding?
      @riding_on.dropped
      @riding_on = nil
    end
  end
  
  def register(scene)
    super(scene)
    
    on :key_press, key(:space) do
      if z == 0 and ok?
        @sounds[:jump].play
        self.velocity_z = JUMP_SPEED
      end
    end
  end

  def velocity_z=(velocity)
    stop_riding if velocity != 0
    super(velocity)
  end

  def velocity_x; @velocity.x; end
  def velocity_x=(velocity)
    @velocity.x = velocity
  end

  def die
    stop_riding if riding?

    @state = :dead
    @effect_time_remaining = nil
    @sprite.sheet_pos = DEAD_SPRITE

    @sounds[:died].play

    scene.game_over(score)
  end

  def finish
    @effect_time_remaining = nil
    @state = :finished

    scene.game_over(score)
  end
  
  def update
    if @tile.is_a? FinishFloor
      stop_riding if riding?

      if z > 0
        @sprite.sheet_pos = JUMP_DOWN_SPRITE
      else
        @player_animations[:dancing].update
      end

      # Empty out all the remaining time in the timer and convert to points, before finishing.
      if scene.timer.out_of_time?
        finish unless finished?
      else
        scene.timer.decrease 0.1, finished: true
        @score += SCORE_PER_100_MS
      end

    elsif scene.timer.out_of_time?
      die unless dead?

    else
      if @state == :ok
        update_physics
        update_animations
      elsif @effect_time_remaining
        @effect_time_remaining -= frame_time
        if @effect_time_remaining <= 0
          case @state
            when :squashed then unsquash
            else
              raise "Bad state: #{state.inspect}"
          end
          @state = :ok
        end
      end

      @tile = scene.floor_map.tile_at_coordinate(position)

      scene.timer.decrease frame_time
    end
    
    super
  end

  def update_riding_position
    @riding_on.position = [position.x + RIDING_OFFSET_X, position.y - 0.00001]
  end

  def update_animations
    if riding?
      # Move back, since our center is a bit forward on the sprite.
      update_riding_position
      @player_animations[:surfing].update
    elsif z == 0
      # Sitting, running or walking.
      vel = effective_velocity.length
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
  end

  def update_physics
    @speed_modifier = @tile.speed if @tile and z == 0 and not riding?

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
  end
end