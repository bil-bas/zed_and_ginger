require_relative "dynamic_object"

class Board < DynamicObject
  ANIMATION_DURATION = 0.5
  DROPPED_SPEED = 40

  def to_rect; Rect.new(*(@position - [4, 1]), 8, 2) end

  def casts_shadow?; true; end

  def initialize(map, tile, position)
    sprite = sprite image_path("board.png"), at: position
    sprite.sheet_size = [2, 1]
    sprite.origin = Vector2[sprite.sprite_width / 2, sprite.sprite_height]
    sprite.scale = [0.75, 0.75]

    super(map.scene, sprite, position)

    @animations << sprite_animation(from: [0, 0], to: [1, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.last.loop!

    @ridden_by = nil
    @dropped = false

    @shadow.scale *= [1.5, 0.4]
  end

  def collide?(other)
    super(other) and other.z == 0
  end

  def dropped
    @ridden_by = nil
    @dropped = true
  end

  def update
    if @dropped
      self.x -= DROPPED_SPEED * frame_time
    else
      scene.players.shuffle.each do |player|
        if not @ridden_by and not @dropped and collide? player
          player.ride self
          @ridden_by = player
          break
        end
      end
    end

    # Force the player to move at a minimum speed if riding.
    if @ridden_by
      @ridden_by.velocity_x = Player::MAX_SPEED / 2 if @ridden_by.velocity_x < 32
    end

    super
  end
end
