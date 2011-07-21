require_relative "floor_tile"

class FinishFloor < FloorTile
  def x; @grid_position.x * width; end

  def initialize(grid_position, offset)
    super([5, 0], grid_position, offset)
  end
end