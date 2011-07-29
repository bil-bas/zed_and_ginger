require_relative "dynamic_object"

class Board < DynamicObject
  ANIMATION_DURATION = 0.5
  DROPPED_SPEED = 40

  def to_rect; Rect.new(*(@position - [2, 1]), 4, 2) end

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

    @ridden = false
    @dropped = false

    @shadow.scale *= [1.5, 0.4]
  end

  def collide?(other)
    super(other) and other.z == 0
  end

  def dropped
    @ridden = false
    @dropped = true
  end

  def update
    if @dropped
      self.x -= DROPPED_SPEED * frame_time
    else
      scene.players.each do |player|
        if not @ridden and not @dropped and collide? player
          player.ride self
          @ridden = true
          break
        end
      end
    end

    super
  end
end
