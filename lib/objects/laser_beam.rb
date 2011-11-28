require_relative 'game_object'

class LaserBeam < GameObject
  MIN_Z = 3.0
  MAX_Z = 21.0

  SPARK_COLOR = Color.new(255, 255, 0, 150)

  def to_rect; Rect.new(*(@position - [0.05, 3]), 0.1, 6) end
  def z_order; super - 3; end # So it appear behind the player.
  def height; 3; end

  def z=(z)
    @sprite.matrix = nil
    @glow.matrix = nil
    super(z)
    @glow.y = @sprite.y
    @glow.skew_x(FloorTile::SKEW * 0.75 / @glow.scale_x)
    @sprite.skew_x(FloorTile::SKEW * 0.75 / @sprite.scale_x)
  end

  def initialize(map, tile, position)
    sprite = sprite image_path("laser_beam.png"), at: position.to_vector2 + [tile.grid_position.y * 3, 0]
    sprite.sheet_size = [2, 1]

    sprite.origin = [sprite.sprite_width + 1.5, sprite.sprite_height * 0.5]
    sprite.scale_x = 0.25
    sprite.scale_y = 0.75

    super(map.scene, sprite, position)
    @glow = @sprite.dup
    @glow.sheet_pos = [1, 0]
    @glow.blend_mode = :add

    self.z = height

    # Add an groove/eye if we are in the position nearest the wall.
    if tile.grid_position.y == 0
      @laser_eye = sprite image_path("laser_eye.png"), at: [position.x, -z]
      @laser_eye.origin = @laser_eye.image.size / 2

      @groove_front = sprite image_path("laser_groove.png"), at: [position.x, 0]
      @groove_front.sheet_size = [2, 1]
      @groove_front.origin = @groove_front.sprite_width * 0.5, @groove_front.sprite_height

      @groove_back = @groove_front.dup
      @groove_back.sheet_pos = [1, 0]
    else
      @laser_eye = nil
    end
  end

  def collide?(other)
    other_z = other.z
    other_z > z - 8 and other_z < z - 1 and super(other)
  end

  def update
    scene.players.each do |player|
      player.burn if player.can_be_hurt? and collide? player
    end

    # Create sparks shooting out from the near-side wall.
    if y > 25
      if rand() < 0.05
        scene.create_particle([x, y + 3, z], velocity: [0, -4, 0], gravity: 0.5, fade_duration: 2,
                              random_velocity: [4, 4, 4], glow: true, color: SPARK_COLOR)

      end

      if frame_number % 4 == 0
        scene.create_particle([x, y + 3, z], scale: 2, gravity: 0, color: SPARK_COLOR,
                              glow: true, fade_duration: 0.5, shrink_duration: 0.65)
      end
    end

    super
  end

  def draw_on(win)
    if @laser_eye
      win.draw @groove_back
      win.draw @laser_eye
      win.draw @groove_front
    end

    super(win)

    @glow.draw_on(win)
  end
end

# Will cut you in half unless you are on the ground.
class LaserBeamShifted < LaserBeam
  def height; 9; end
end

