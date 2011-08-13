require_relative "floor_tile"

class DirtFloor < FloorTile
  def x; @grid_position.x * width; end

  def initialize(grid_position, offset)
    super([2, 2], grid_position, offset)
  end
end