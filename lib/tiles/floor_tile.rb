require_relative "tile"

class FloorTile < Tile
  SKEW = 0.5
  IMAGE_SIZE = Vector2[64, 64] # Size of the tiles sprite-sheet.

  def speed_multiplier; 1.0; end

  attr_accessor :push_velocity

  class << self
    def height; 6; end
    def width; 8; end
  end

  def initialize(sprite_position, grid_position, offset)
    super(image_path("tiles.png"), sprite_position, grid_position, offset)
    @sprite.x += grid_position.y * height * SKEW
    @sprite.scale_y = height / width.to_f
    @sprite.skew_x(SKEW * @sprite.scale_y)

    @push_velocity = Vector2[0, 0] # Unless tile has a conveyor on it, no push.
  end
end