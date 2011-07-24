require_relative "tile"

class FloorTile < Tile
  SKEW = 0.5

  def speed; 1.0; end

  class << self
    def height; 6; end
    def width; 8; end
  end

  def initialize(sprite_position, grid_position, offset)
    super(image_path("floor_tiles.png"), sprite_position, grid_position, offset)
    @sprite.x += grid_position.y * height * SKEW
    @sprite.scale_y = height / width.to_f
    @sprite.skew_x(SKEW * @sprite.scale_y)
  end
end