require_relative "game_object"

class FlyTrap < GameObject
  def to_rect; Rect.new(*(@position - [3, 2.5]), 6, 5) end
  def z_order; @digesting ? super : Player::Z_ORDER_SQUASHED - 1; end # So it appear under the player when flat.

  def initialize(map, tile, position)
    sprite = sprite image_path("fly_trap.png"), at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    sprite.sheet_size = [7, 1]
    sprite.scale *= 0.75
    @sprite_flat = sprite.dup
    sprite.origin = [sprite.sprite_width / 2, sprite.sprite_height - 1]

    super(map.scene, sprite, position)

    @sprite_flat.origin = [@sprite_flat.sprite_width / 2 + 1, @sprite_flat.sprite_height / 2]
    @sprite_flat.scale_y = 0.75
    @sprite_flat.skew_x(FloorTile::SKEW * 0.75)

    @shadow.scale *= [1.2, 0.4]

    @digesting = nil
    @activated_at = 0

    @chew_sound = sound sound_path("fly_trap_chew.ogg")
    @chew_sound.volume = 5 * (scene.user_data.effects_volume / 50.0)
    @chew_sound.looping = true

    @snap_sound = sound sound_path("fly_trap_snap.ogg")
    @snap_sound.volume = 50 * (scene.user_data.effects_volume / 50.0)
  end

  def collide?(other)
    other.z < 2 and super(other)
  end

  def update
    if @digesting
      time = scene.timer.elapsed - @activated_at
      frame = [1, 2, 3, 4, 5, 4, 6, 4][time * 6]
      if frame
        @sprite.sheet_pos = [frame, 0]
      else
        @chew_sound.stop
        @digesting.remove_status :eaten

        @digesting = nil
      end
    else
      scene.players.shuffle.each do |player|
        if player.can_be_hurt? and collide? player
          player.eaten
          player.x, player.y, player.z = x, y, z + 4
          @activated_at = scene.timer.elapsed
          @sprite.sheet_pos = [1, 0]
          @chew_sound.play
          @snap_sound.play
          @digesting = player
        end
      end
    end

    super
  end

  def draw_on(win)
    if @digesting
      super
    else
      win.draw @sprite_flat
    end
  end
end