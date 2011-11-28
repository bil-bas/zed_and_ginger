require_relative "dynamic_object"
require_relative "../tiles/floor_tile"

require_files('statuses', %w[burnt eaten electrocuted hyper_speed in_cutscene invulnerable squashed thrown])

class Player < DynamicObject
  include HasStatus

  ANIMATION_DURATION = 2

  ACCELERATION = 100.0
  DECELERATION = -100.0
  MIN_SPEED = 0.0
  MAX_SPEED = 60.0
  VERTICAL_SPEED = 25.0
  MIN_RUN_VELOCITY = 1000.0 # Above this, run animation; below walk.
  JUMP_SPEED = 65 # Z-speed of jumping.

  RIDING_OFFSET_X = -2 # Move ridden object back, since we have our origin far forward.
  SQUASH_OFFSET_Y = 3 # Distance moved when squashed.

  FOUR_FRAME_ANIMATION_DURATION = 1

  SCORE_PER_TILE = 50

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
  ELECTROCUTED_SPRITE = [2, 4]
  THROWN_SPRITE = [3, 4]
  AFTER_THROWN_SPRITE = [4, 4]
  BLANK_SPRITE = [7, 2] # Should we not want to be seen.

  Z_ORDER_SQUASHED = -10

  # Screen is 12 wide (+2 for skew).
  LOOK_BEHIND = FloorTile.width * 0.5
  MIN_LOOK_AHEAD = FloorTile.width * 7.5 # Will appear further forward if moved by external force.
  MAX_LOOK_AHEAD = FloorTile.width * 11.5
  LOOK_AHEAD_RANGE = MAX_LOOK_AHEAD - MIN_LOOK_AHEAD

  NAMES = [:zed, :ginger]

  attr_reader :name
  attr_accessor :max_speed, :speed_multiplier

  def shadow_width; 1.2; end
  def shadow_height; 0.6; end

  def casts_shadow?; (not squashed?); end
  def z_order; squashed? ? Z_ORDER_SQUASHED : super; end
  def to_rect; Rect.new(*(@position - [3, 2]), 6, 4) end
  def riding?; !!@riding_on; end
  def ok?; @state == :ok; end
  def dead?; @state == :dead; end
  def finished?; @state == :finished; end
  # Score gained purely by number of tiles travelled.
  def distance_score; ((x - @initial_x).div(8) * SCORE_PER_TILE); end
  def score; @score + distance_score; end
  def score=(score); @score = score - distance_score; end
  def can_be_hurt?; not disabled? :hurt; end

  def velocity_z=(velocity)
    stop_riding if velocity != 0
    super(velocity)
  end

  def velocity_y=(velocity)
    @velocity.y = velocity
  end

  def velocity_x; @velocity.x; end
  def velocity_x=(velocity)
    @velocity.x = velocity
  end

  def push_velocity=(velocity); @push_velocity = velocity.to_vector2; end
  def acceleration_forced?; @acceleration_forced; end
  def acceleration_forced=(forced); @acceleration_forced = forced; end

  def to_s; "Player##{@name}"; end

  public
  def initialize(scene, tile, position, sprite_sheet, name)
    @initial_x = position.x
    @name = name

    sprite = sprite sprite_sheet
    sprite.sheet_size = [8, 5]
    sprite.sheet_pos = SITTING_ANIMATION.first
    sprite.origin = [sprite.sprite_width * 2.0 / 3.0, sprite.sprite_height - 1]

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
    @speed_multiplier = 1.0
    @score = 0

    @push_velocity = Vector2[0, 0] # Pushed by conveyor, for example.
    @max_speed = MAX_SPEED

    @sounds = {}
    [:died, :jump].each do |sound|
      @sounds[sound] = sound sound_path "player_#{sound}.ogg"
    end
    @sounds[:died].volume = 30 * (scene.user_data.effects_volume / 50.0)
    @sounds[:jump].volume = 15 * (scene.user_data.effects_volume / 50.0)

    create_animations

    log.info { "#{self} playing with controls: #{@controls}" }
  end

  protected
  def read_controls
    @controls = {}
    [:left, :right, :up, :down, :jump].each do |control|
      @controls[control] = scene.user_data.player_control(@name, control)
    end

    if scene.inversion?
      @controls[:up], @controls[:down] = @controls[:down], @controls[:up]
    end
  end

  public
  # Range of the world that _must_ be visible for the player.
  def view_range_x
    (x - LOOK_BEHIND)..(x + MIN_LOOK_AHEAD + LOOK_AHEAD_RANGE * (1 - velocity_x / MAX_SPEED) )
  end

  protected
  def effective_velocity
    @velocity * @speed_multiplier + @push_velocity
  end

  protected
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

  public
  def ride(object)
    @riding_on = object
  end

  public
  def stop_riding
    if riding?
      @riding_on.dropped
      @riding_on = nil
    end
  end

  public
  def register(scene)
    super(scene)

    read_controls

    on :key_press, *key_or_code(@controls[:jump]) do
      jump if ok? unless disabled? :animation or disabled? :controls
    end
  end

  public
  def jump
    if z == 0 and (riding? or not @tile.is_a? GlueFloor)
      @sounds[:jump].pitch = 0.8 + rand(3) * 0.1
      @sounds[:jump].play
      self.velocity_z = JUMP_SPEED
      self.z += 0.000001 # Prevent multiple jumps.
    end
  end

  public
  def die(options = {})
    lose

    @sounds[:died].play

    scene.game_over(self)
  end

  public
  # Called directly, the other player finished first.
  def lose
    stop_riding if riding?

    @state = :dead
    @sprite.sheet_pos = DEAD_SPRITE
  end

  public
  def update
    if finished?
      if z > 0
        @sprite.sheet_pos = JUMP_DOWN_SPRITE
      else
        @player_animations[:dancing].update
      end

    elsif @tile.is_a? FinishFloor
      stop_riding if riding?
      @state = :finished
      scene.game_over(self)

    elsif scene.timer.out_of_time?
      die unless dead?

    else
      case @state
        when :ok
          if @tile
            if z > 0
              @push_velocity = Vector2[0, 0]
              @speed_multiplier = 1.0 if riding?
            elsif
              @speed_multiplier = @tile.speed_multiplier
              @push_velocity = @tile.push_velocity
            end
          end

          update_controls  unless disabled? :controls
          update_physics   unless disabled? :physics
          update_animation unless disabled? :animation
      end

      @tile = scene.floor_map.tile_at_coordinate(position)
    end
    
    super
  end

  public
  def update_riding_position
    @riding_on.position = [position.x + RIDING_OFFSET_X, position.y - 0.00001]
  end

  protected
  def update_animation
    if riding?
      # Move back, since our center is a bit forward on the sprite.
      update_riding_position
      @player_animations[:surfing].update
    elsif z == 0
      # Sitting, running or walking.
      vel = effective_velocity.length
      if @velocity == [0, 0] # Could be being pushed.
        @player_animations[:sitting].update
      elsif vel >= MIN_RUN_VELOCITY
        @player_animations[:running].duration = (100 - vel) / 20.0
        @player_animations[:running].update
      else
        @player_animations[:walking].duration = (100 - vel) / 20.0
        @player_animations[:walking].update
      end
    else
      # Jumping up, down or across (last at apex of jump).
      if @velocity_z > 10
        @sprite.sheet_pos = JUMP_UP_SPRITE
      elsif @velocity_z < -10
        @sprite.sheet_pos = JUMP_DOWN_SPRITE
      else
        @sprite.sheet_pos = JUMP_ACROSS_SPRITE
      end
    end
  end

  protected
  def update_controls
    # Move up and down.
    @velocity.y = if holding? @controls[:up]
      -VERTICAL_SPEED
    elsif holding? @controls[:down]
      +VERTICAL_SPEED
    else
      0
    end

    # Accelerate and decelerate.
    if acceleration_forced? or holding? @controls[:right]
      @velocity.x += ACCELERATION * frame_time
      @velocity.x = [@velocity.x, @max_speed].min
    elsif holding? @controls[:left]
      @velocity.x += DECELERATION * frame_time
      @velocity.x = [@velocity.x, MIN_SPEED].max
    end 
  end

  protected
  def update_physics
    if DEVELOPMENT_MODE
      if z > 0
        @jumped_x ||= x
        scene.create_particle([x, y, z], gravity: 0, scale: 0.5, color: Color.red, fade_duration: 4)
        log.debug { "#{self} apex height: #{z}" } if @velocity_z < +5 and @velocity_z > -5
      elsif z == 0
        if @jumped_x
          log.debug { "Jumped for #{x - @jumped_x} pixels" }
          @jumped_x = nil
        end
      end
    end

    self.position += effective_velocity * frame_time

    self.y = [[position.y, @rect.y].max, @rect.y + @rect.height].min
  end

  public
  def squash(options = {})
    die if scene.hardcore?

    apply_status :squashed, options
  end

  public
  def electrocute(options = {})
    die if scene.hardcore?

    apply_status :electrocuted, options
  end

  public
  def burn(options = {})
    die if scene.hardcore?

    apply_status :burnt, options
  end

  public
  def throw(velocity)
    die if scene.hardcore?

    apply_status :thrown
    _, self.velocity_y, self.velocity_z = velocity
  end

  public
  def eaten(options = {})
    die if scene.hardcore?

    apply_status :eaten, options
  end
end