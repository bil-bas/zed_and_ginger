require_relative 'game_object'

class LaserBeam < GameObject
  MIN_Z = 3.0
  MAX_Z = 21.0
  Z_DIFFERENCE = 24 # Moves from 0..24 at linear speed, but limited at 3..21 (stops at the ends)
  SPEED = 10.0

  SPARK_COLOR = Color.new(255, 255, 0, 150)

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
    color = sprite.color
    color.alpha = 150
    sprite.color = color

    # Add an eye if we are in the position nearest the wall.
    if tile.grid_position.y == 0
      @laser_eye = sprite image_path("laser_eye.png"), at: [position.x, 0]
      @laser_eye.origin = @laser_eye.image.size / 2
    else
      @laser_eye = nil
    end

    super(map.scene, sprite, position)
  end

  def collide?(other)
    other_z = other.z
    other_z > z - 7 and other_z < z + 1 and super(other)
  end

  def update
    # Can't use an animation, since we want all animations to synchronize (even if not animated).
    z_offset = ((scene.timer.elapsed * SPEED) + phase_shift) % (Z_DIFFERENCE * 2) # 0..(2*height)
    z_offset = Z_DIFFERENCE * 2 - z_offset if z_offset > Z_DIFFERENCE
    self.z = [[z_offset, MIN_Z].max, MAX_Z].min

    @laser_eye.y = -self.z if @laser_eye

    scene.players.each do |player|
      player.burn if player.can_be_hurt? and collide? player
    end

    if y > 25 and rand() < 0.25
      scene.create_particle([x, y + 3, z], velocity: [0, -2, 0], scale: [0.5, 0.5],
          random_velocity: [5, 2, 1], glow: true, color: SPARK_COLOR, fade_duration: 2.5)
    end
  end

  def draw_on(win)
    win.draw @laser_eye if @laser_eye
    super(win)
  end
end

class LaserBeamShifted < LaserBeam
  def phase_shift; Z_DIFFERENCE; end
end

