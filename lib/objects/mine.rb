require_relative "game_object"

class Mine < GameObject
  ANIMATION_DURATION = 1
  EXPLOSION_FORCE = 2.5 # Speed upwards.

  EXPLODED_SPRITE = [3, 0]

  def z_order; Player::Z_ORDER_SQUASHED - 1; end
  def to_rect; Rect.new(*(@position - [2, 1.5]), 4, 3) end

  def initialize(map, tile, position)
    sprite = sprite image_path("mine.png"), at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    sprite.sheet_size = [4, 1]
    sprite.origin = Vector2[sprite.sprite_width / 2, sprite.sprite_height / 2]
    sprite.scale_y = 0.75
    sprite.skew_x(FloorTile::SKEW * 0.75)

    super(map.scene, sprite, position)

    @animation = sprite_animation(from: [0, 0],
                                    to: [2, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animation.loop!

    @explosion = sound sound_path "mine_explosion.ogg"
    @explosion.volume = 30 * (scene.user_data.effects_volume / 50.0)

    @active = true
  end

  def collide?(other)
    other.z == 0 and super(other) and not other.riding?
  end

  def update
    if @active
      scene.players.shuffle.each do |player|
        if player.can_be_hurt? and collide? player
          player.throw(Vector3[0, 0, EXPLOSION_FORCE])

          @sprite.sheet_pos = EXPLODED_SPRITE
          @explosion.play

          scene.create_particle([x, y, z + 1], velocity: [0, 0, 50], number: 10, gravity: 0, glow: true,
              random_velocity: [25, 10, 25], color: Color.new(255, 150, 75, 200), scale: [1.5, 1.5], fade_duration: 1)

          scene.create_particle([x, y, z + 1], velocity: [0, 0, 2.5], number: 10, gravity: -0.5,
                    random_velocity: [3, 3, 2.5], color: Color.new(0, 0, 0, 150), scale: [2, 2], fade_duration: 5)

          @active = false
        end
      end

      @animation.update if @active
    end
  end
end
