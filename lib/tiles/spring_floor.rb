require_relative "floor_tile"

class SpringFloor < FloorTile
  def x; @grid_position.x * width; end

  def initialize(grid_position, offset)
    super([2, 1], grid_position, offset)
  end
end