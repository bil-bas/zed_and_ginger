require_relative "dynamic_object"
require_relative "float_icon"

class Rat < DynamicObject
  OK_SPRITE = [0, 0]
  CHASED_SPRITE = [1, 0]
  SQUASHED_SPRITE = [2, 0]

  SQUASHED_EXTRA_TIME = 1 # Extra 1 second when you squash/eat the mouse.
  TOUCHED_SCORE = 100
  RUN_SPEED = -40

  def casts_shadow?; @state != :squashed; end
  def z_order; @state == :squashed ? Player::Z_ORDER_SQUASHED - 1 : super; end
  def to_rect; Rect.new(*(@position - [1.5, 1.5]), 3, 3) end

  def initialize(map, tile, position)
    sprite = sprite image_path("rat.png"), at: position
    sprite.sheet_size = [3, 1]
    sprite.origin = Vector2[sprite.sprite_width / 2, sprite.sprite_height]
    sprite.scale = [0.5, 0.5]

    @state = :ok
    @speed = 0

    super(map.scene, sprite, position)

    @sounds = {}
    [:chased, :squashed].each do |sound|
      @sounds[sound] = sound sound_path "rat_#{sound}.ogg"
    end
    @sounds.each_value {|s| s.volume = 30 }

    @shadow.scale *= [0.4, 0.2]
  end

  def collide?(other)
    other.z <= 2 and super(other)
  end

  def update
    scene.players.each do |player|
      if player.ok? and collide? player and @state == :ok
        if player.velocity_z < 0
          @sprite.sheet_pos = SQUASHED_SPRITE
          scene.timer.increase SQUASHED_EXTRA_TIME
          @state = :squashed
          @sprite.y += 2
          @sounds[:squashed].play
          FloatIcon.new(:extra_time, player)
        else
          @sprite.sheet_pos = CHASED_SPRITE
          player.score += TOUCHED_SCORE
          @state = :chased
          @sounds[:chased].play
          @speed = RUN_SPEED
        end

        break
      end
    end

    self.x += @speed * frame_time if @state == :chased
  end
end
