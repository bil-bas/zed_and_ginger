require_relative "tile"

class WallTile < Tile
  def speed; 1.0; end

  class << self
    def height; 8; end
    def width; 8; end
  end

  def initialize(sprite_position, grid_position, offset)
    super(image_path("wall_tiles.png"), sprite_position, grid_position, offset)
  end
end