require_relative "dynamic_object"

class Rat < DynamicObject
  OK_SPRITE = [0, 0]
  RUNNING_SPRITE = [1, 0]
  SQUASHED_SPRITE = [2, 0]

  SQUASHED_TIMER_PAUSE = 1
  TOUCHED_SCORE = 100
  RUN_SPEED = -40

  def casts_shadow?; @state != :squashed; end
  def z_order; @state == :squashed ? -0.1 : super; end
  def to_rect; Rect.new(*(@position - [0.5, 0.5]), 1, 1) end

  def initialize(scene, position)
    sprite = sprite image_path("rat.png"), at: position
    sprite.sheet_size = [3, 1]
    sprite.origin = Vector2[sprite.sprite_width / 2, sprite.sprite_height]
    sprite.scale = [0.5, 0.5]

    @state = :ok
    @speed = 0

    super(scene, sprite, position)

    @shadow.scale *= [0.3, 0.3]
  end

  def collide?(other)
    other.z <= 2 and super(other)
  end

  def update
    player = scene.player
    if player.ok? and collide? player and @state == :ok
      if player.velocity_z < 0
        @sprite.sheet_pos = SQUASHED_SPRITE
        player.pause_timer SQUASHED_TIMER_PAUSE
        @state = :squashed
        @sprite.origin.y -= 3
      else
        @sprite.sheet_pos = RUNNING_SPRITE
        player.score += TOUCHED_SCORE
        @state = :running
        @speed = RUN_SPEED
      end
    end

    self.x += @speed * frame_time if @state == :running
  end
end