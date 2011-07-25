require_relative 'game_object'

class LaserBeam < GameObject
  MOVE_SPEED = 5
  MIN_Z = 2
  MAX_Z = 22

  def to_rect; Rect.new(*(@position - [0, 3]), 0, 6) end
  def z_order; super - 3; end # So it appear behind the player.
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

    @velocity_z = initial_speed

    self.z = initial_z # Make me move to the correct height, before I get skewed.

    recalculate_direction
  end

  def recalculate_direction
    if z <= MIN_Z or not defined? @velocity_z
      @velocity_z = + MOVE_SPEED
      self.z = MIN_Z + (MIN_Z - z)
    elsif z >= MAX_Z
      @velocity_z = - MOVE_SPEED
      self.z = MAX_Z - (z - MAX_Z)
    end
  end

  def collide?(other)
    other.z.between?(z - 7, z + 1) and super(other)
  end

  def update
    self.z += @velocity_z * frame_time
    recalculate_direction

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

# Starts at the top and moves down.
class HighLaserBeam < LaserBeam
  def initial_z; MAX_Z; end
  def initial_speed; - MOVE_SPEED; end
end

# Starts at the bottom, moving up.
class LowLaserBeam < LaserBeam
  def initial_z; MIN_Z; end
  def initial_speed; + MOVE_SPEED; end
end