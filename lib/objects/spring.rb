require_relative "game_object"

class Spring < GameObject
  JUMP_Z_SPEED = 80
  JUMP_SPEED_MODIFIER = 1.3

  def to_rect; Rect.new(*(@position - [2, 1.5]), 4, 3) end

  def initialize(map, tile, position)
    img = image image_path("spring.png")
    @sprite_flat = sprite img, at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    @sprite_flat.sheet_size = [2, 1]

    @sprite_flat.origin = Vector2[@sprite_flat.sprite_width / 2, @sprite_flat.sprite_height / 2]
    @sprite_flat.scale_y = 0.75
    @sprite_flat.skew_x(FloorTile::SKEW * 0.75)

    @sprite_strut = sprite img, at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    @sprite_strut.sheet_size = [2, 1]
    @sprite_strut.sheet_pos = [1, 0]
    @sprite_strut.origin = Vector2[@sprite_strut.sprite_width / 2 - 2, @sprite_strut.sprite_height - 3]

    @activated = false

    super(map.scene, @sprite_flat, position)

    @bounce_sound = sound sound_path "spring_bounce.ogg"
    @bounce_sound.volume = 30 * (scene.user_data.effects_volume / 50.0)
  end

  def z_order
    @activated ? super - 3 : Player::Z_ORDER_SQUASHED - 1
  end

  def collide?(other)
    super(other) and other.z == 0
  end

  def update
    scene.players.shuffle.each do |player|
      if player.ok? and not @activated and collide? player
        @sprite_flat.matrix = nil
        @sprite_flat.position += [-1.5, -4]
        @sprite_flat.skew_x(FloorTile::SKEW * 0.75)

        player.z += 0.000001 # Just so we only collide with ONE spring.
        player.velocity_z = JUMP_Z_SPEED
        @bounce_sound.play
        player.speed_modifier = JUMP_SPEED_MODIFIER
        @activated = true
        break
      end
    end

    super
  end

  def draw_on(win)
    win.draw @sprite_strut if @activated
    win.draw @sprite_flat
  end
end
