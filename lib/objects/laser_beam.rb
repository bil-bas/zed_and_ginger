require_relative 'game_object'

class LaserBeam < GameObject
  MIN_Z = 1.0
  MAX_Z = 23.0
  Z_DIFFERENCE = MAX_Z - MIN_Z
  SPEED = 5.0

  def to_rect; Rect.new(*(@position - [0, 3]), 0, 6) end
  def z_order; super - 3; end # So it appear behind the player.
  def phase_shift; 0; end

  def z=(z)
    @sprite.matrix = nil
    super(z)
    @sprite.skew_x(FloorTile::SKEW * 0.75)
  end

  def initialize(map, tile, position)
    sprite = sprite image_path("laser_beam.png"), at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    sprite.sheet_size = [1, 1]
    sprite.origin = Vector2[sprite.sprite_width / 2 + 1.5, sprite.sprite_height / 2]
    sprite.scale_y = 0.75

    super(map.scene, sprite, position)
  end

  def collide?(other)
    other.z.between?(z - 7, z + 1) and super(other)
  end

  def update
    # Can't use an animation, since we want all animations to synchronize (even if not animated).
    z_offset = ((scene.timer.elapsed * SPEED) + phase_shift) % (Z_DIFFERENCE * 2) # 0..(2*height)
    z_offset = Z_DIFFERENCE * 2 - z_offset if z_offset > Z_DIFFERENCE
    self.z = MIN_Z + z_offset

    player = scene.player
    if player.ok? and collide? player
      player.squash
      # Remove all sections of the beam.
      scene.objects.grep(self.class).select {|o| o.x == x }.each do |laser|
        scene.remove_object laser
      end
    end
  end
end

class LaserBeamShifted < LaserBeam
  def phase_shift; Z_DIFFERENCE; end
end

