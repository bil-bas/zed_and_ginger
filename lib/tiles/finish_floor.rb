require_relative "floor_tile"

class FinishFloor < FloorTile
  def initialize(grid_position, offset)
    super([5, 0], grid_position, offset)
  end
end